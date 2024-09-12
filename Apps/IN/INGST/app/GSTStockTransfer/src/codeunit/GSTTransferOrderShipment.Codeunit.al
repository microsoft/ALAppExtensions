// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.GST.Application;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Transfer;
using System.Reflection;

codeunit 18391 "GST Transfer Order Shipment"
{
    SingleInstance = True;

    var
        TempGSTPostingBufferStage: Record "GST Posting Buffer" temporary;
        TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary;
        TempTransferBufferStage: Record "Transfer Buffer" temporary;
        TempTransferBufferFinal: Record "Transfer Buffer" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GSTBaseValidation: Codeunit "GST Base Validation";
        TransferCost: Decimal;
        TransferQuantity: Decimal;
        GSTGroupServiceErr: Label 'You canNot select GST Group Type Service for transfer.';
        LocGSTRegNoARNNoErr: Label 'Location must have either GST Registration No. or Location ARN No.';
        TransferShipmentNoLbl: Label 'Transfer - %1', Comment = '%1= Transfer Shipment No.';

    procedure UpdateGSTTrackingEntryFromTransferOrder(DocumentNo: Code[20]; ItemNo: Code[20]; DocumentLineNo: Integer; OrignalDocType: Enum "Original Doc Type")
    var
        GSTTrackingEntry: Record "GST Tracking Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateGSTTrackingEntryFromTransferOrder(DocumentNo, ItemNo, DocumentLineNo, OrignalDocType, IsHandled);
        if IsHandled then
            exit;

        ItemLedgerEntry.SetRange("Document No.", DocumentNo);
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange(Open, true);
        if ItemLedgerEntry.FindSet() then
            repeat
                GSTTrackingEntry.Init();
                GSTTrackingEntry."Entry No." := 0;
                GSTTrackingEntry."From Entry No." := GetFromEntryNo(DocumentNo, DocumentLineNo, OrignalDocType);
                GSTTrackingEntry."From To No." := GetToEntryNo(DocumentNo, DocumentLineNo, OrignalDocType);
                GSTTrackingEntry."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
                GSTTrackingEntry.Quantity := ItemLedgerEntry.Quantity;
                GSTTrackingEntry."Remaining Quantity" := ItemLedgerEntry."Remaining Quantity";
                GSTTrackingEntry.Insert(true);
            until ItemLedgerEntry.Next() = 0;
    end;

    local procedure GetGSTReceivableAccountNo(LocationCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Reset();
        GSTPostingSetup.SetRange("State Code", LocationCode);
        GSTPostingSetup.SetRange("Component ID", GSTComponentID(GSTComponentCode));
        GSTPostingSetup.FindFirst();
        exit(GSTPostingSetup."Receivable Account")
    end;

    local procedure GSTComponentID(ComponentCode: Code[30]): Integer
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        GSTSetup.TestField("Cess Tax Type");
        TaxComponent.SetFilter("Tax Type", '%1|%2', GSTSetup."GST Tax Type", GSTSetup."Cess Tax Type");
        TaxComponent.SetRange(Name, ComponentCode);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Id)
    end;

    procedure LoopPostingNoSeries(var PostingNoSeries: Record "Posting No. Series"; Record: Variant; PostingDocumentType: Enum "Posting Document Type"): Code[20]
    var
        Filters: Text;
    begin
        PostingNoSeries.SetRange("Document Type", PostingDocumentType);
        if PostingNoSeries.FindSet() then
            repeat
                Filters := GetRecordView(PostingNoSeries);
                if RecordViewFound(Record, Filters) then begin
                    PostingNoSeries.TestField("Posting No. Series");
                    exit(PostingNoSeries."Posting No. Series");
                end;
            until PostingNoSeries.Next() = 0;
    end;

    procedure InsertGSTLedgerEntryTransfer(
        GSTPostingBuffer: Record "GST Posting Buffer";
        TransferHeader: Record "Transfer Header";
        NextTransactionNo: Integer;
        DocumentNo: Code[20];
        SourceCode: Code[10];
        DocTransferType: enum "Doc Transfer Type")
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        Location: Record Location;
        IsHandled: Boolean;
    begin
        OnBeforeInsertGSTLedgerEntryTransfer(GSTPostingBuffer, TransferHeader, NextTransactionNo, DocumentNo, SourceCode, DocTransferType, IsHandled);
        if IsHandled then
            exit;

        Location.Get(TransferHeader."Transfer-from Code");

        if GSTPostingBuffer."GST Amount" = 0 then
            exit;

        GSTLedgerEntry.Init();
        GSTLedgerEntry."Entry No." := 0;
        GSTLedgerEntry."Gen. Bus. Posting Group" := GSTPostingBuffer."Gen. Bus. Posting Group";
        GSTLedgerEntry."Gen. Prod. Posting Group" := GSTPostingBuffer."Gen. Prod. Posting Group";
        GSTLedgerEntry."Posting Date" := TransferHeader."Posting Date";
        GSTLedgerEntry."Document No." := DocumentNo;
        GSTLedgerEntry."Document Type" := GSTLedgerEntry."Document Type"::Invoice;
        GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::Transfer;
        if DocTransferType = DocTransferType::"Transfer Shipment" then begin
            GSTLedgerEntry."Transaction Type" := GSTLedgerEntry."Transaction Type"::Sales;
            GSTLedgerEntry."External Document No." := TransferHeader."No.";
            GSTLedgerEntry."GST Base Amount" := -GSTPostingBuffer."GST Base Amount";
            GSTLedgerEntry."GST Amount" := -GSTPostingBuffer."GST Amount";
        end else begin
            GSTLedgerEntry."Transaction Type" := GSTLedgerEntry."Transaction Type"::Purchase;
            GSTLedgerEntry."External Document No." := TransferHeader."Last Shipment No.";
            GSTLedgerEntry."GST Base Amount" := GSTPostingBuffer."GST Base Amount";
            GSTLedgerEntry."GST Amount" := GSTPostingBuffer."GST Amount";
            if Location."Bonded warehouse" then begin
                GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::VEndor;
                GSTLedgerEntry."Source No." := TransferHeader."VEndor No.";
                GSTLedgerEntry."Reverse Charge" := true;
            end;
        end;

        GSTLedgerEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(GSTLedgerEntry."User ID"));
        GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::Transfer;
        GSTLedgerEntry."Source Code" := SourceCode;
        GSTLedgerEntry."Transaction No." := NextTransactionNo;
        GSTLedgerEntry."GST Component Code" := GSTPostingBuffer."GST Component Code";
        OnAfterUpdateOnBeforeInsertGSTLedgerEntryTransfer(GSTPostingBuffer, TransferHeader, GSTLedgerEntry);
        GSTLedgerEntry.Insert(true);
    end;

    procedure InsertDetailedGSTLedgEntryTransfer(
        var TransferLine: Record "Transfer Line";
        TransferHeader: Record "Transfer Header";
        DocumentNo: Code[20];
        TransactionNo: Integer;
        DocTransferType: Enum "Doc Transfer Type")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        Location: Record Location;
        Location2: Record Location;
        TaxTransactionValue: Record "Tax Transaction Value";
        ShipRcvQuantity: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeInsertDetailedGSTLedgEntryTransfer(TransferLine, TransferHeader, DocumentNo, TransactionNo, DocTransferType, IsHandled);
        if IsHandled then
            exit;

        if (TransferLine."GST Group Code" = '') or (TransferLine."HSN/SAC Code" = '') then
            exit;

        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Record ID", TransferLine.RecordId);
        if TaxTransactionValue.IsEmpty then
            exit;

        Location.Get(TransferHeader."Transfer-from Code");
        if not Location."Bonded warehouse" then begin
            Location.TestField("State Code");
            if (Location."GST Registration No." = '') and (Location."Location ARN No." = '') then
                Error(LocGSTRegNoARNNoErr);
        end;

        Location2.Get(TransferHeader."Transfer-to Code");
        if (Location2."GST Registration No." = '') and (Location2."Location ARN No." = '') then
            Error(LocGSTRegNoARNNoErr);

        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::Transfer);
        DetailedGSTEntryBuffer.SetRange("Document Type", 0);
        DetailedGSTEntryBuffer.SetRange("Document No.", TransferLine."Document No.");
        DetailedGSTEntryBuffer.SetRange("Line No.", TransferLine."Line No.");
        DetailedGSTEntryBuffer.SetFilter("GST Amount", '<>%1', 0);
        if DetailedGSTEntryBuffer.FindSet() then
            repeat
                DetailedGSTLedgerEntry.Init();
                DetailedGSTLedgerEntry."Entry No." := 0;
                DetailedGSTLedgerEntry."Entry Type" := DetailedGSTLedgerEntry."Entry Type"::"Initial Entry";
                if DocTransferType = DocTransferType::"Transfer Shipment" then
                    DetailedGSTLedgerEntry."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type"::Sales
                else
                    DetailedGSTLedgerEntry."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type"::Purchase;

                DetailedGSTLedgerEntry."Document Type" := DetailedGSTLedgerEntry."Document Type"::Invoice;
                DetailedGSTLedgerEntry."Document No." := DocumentNo;
                DetailedGSTLedgerEntry."Posting Date" := TransferHeader."Posting Date";
                DetailedGSTLedgerEntry.Type := DetailedGSTLedgerEntry.Type::Item;
                DetailedGSTLedgerEntry."Product Type" := DetailedGSTLedgerEntry."Product Type"::Item;
                DetailedGSTLedgerEntry."No." := TransferLine."Item No.";
                DetailedGSTLedgerEntry."GST Jurisdiction Type" := GETGSTJurisdictionType(TransferHeader);
                DetailedGSTLedgerEntry."GST Group Type" := "GST Group Type"::Goods;
                DetailedGSTLedgerEntry."GST Without Payment of Duty" := false;
                DetailedGSTLedgerEntry."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                DetailedGSTLedgerEntry."GST Exempted Goods" := TransferLine.Exempted;
                if DocTransferType = DocTransferType::"Transfer Shipment" then begin
                    DetailedGSTLedgerEntry."G/L Account No." := GetGSTPayableAccountNo(Location."State Code", DetailedGSTEntryBuffer."GST Component Code");
                    ShipRcvQuantity := TransferLine."Qty. to Ship (Base)";
                    FillDetailedGSTLedgerEntryShipment(DetailedGSTLedgerEntry, Location, Location2, TransferHeader);
                end else begin
                    DetailedGSTLedgerEntry."G/L Account No." := GetGSTReceivableAccountNo(Location2."State Code", DetailedGSTEntryBuffer."GST Component Code");
                    ShipRcvQuantity := TransferLine."Qty. to Receive (Base)";
                    FillDetailedGSTLedgerEntryReceipt(DetailedGSTLedgerEntry, Location, Location2, TransferHeader, TransferLine);
                end;

                UpdateDetailedGSTLedgerEntryTransfer(
                  DetailedGSTLedgerEntry,
                  TransferLine."Document No.",
                  TransferLine."Line No.",
                  TransactionNo,
                  TransferLine."Quantity (Base)",
                  ShipRcvQuantity,
                  DocTransferType);
                DetailedGSTLedgerEntry.TestField("HSN/SAC Code");
                DetailedGSTLedgerEntry."Skip Tax Engine Trigger" := true;
                DetailedGSTLedgerEntry.Insert(true);

                InsertDetailedGSTEntryInfoTransfer(DetailedGSTLedgerEntry, DetailedGSTEntryBuffer, TransferHeader, DocTransferType);
            until DetailedGSTEntryBuffer.Next() = 0;
    end;

    local procedure InsertDetailedGSTEntryInfoTransfer(
            DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
            DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
            TransferHeader: Record "Transfer Header";
            DocTransferType: Enum "Doc Transfer Type")
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        Location: Record Location;
        Location2: Record Location;
        IsHandled: Boolean;
    begin
        OnBeforeInsertDetailedGSTEntryInfoTransfer(DetailedGSTLedgerEntry, DetailedGSTEntryBuffer, TransferHeader, DocTransferType, IsHandled);
        if IsHandled then
            exit;

        Location.Get(TransferHeader."Transfer-from Code");
        Location2.Get(TransferHeader."Transfer-to Code");

        DetailedGSTLedgerEntryInfo.Init();
        DetailedGSTLedgerEntryInfo."Entry No." := DetailedGSTLedgerEntry."Entry No.";
        DetailedGSTLedgerEntryInfo."Original Doc. No." := TransferHeader."No.";
        DetailedGSTLedgerEntryInfo.Positive := DetailedGSTLedgerEntry."GST Amount" > 0;
        DetailedGSTLedgerEntryInfo."User ID" := CopyStr(UserId, 1, MaxStrLen(DetailedGSTLedgerEntryInfo."User ID"));
        DetailedGSTLedgerEntryInfo.Cess := DetailedGSTEntryBuffer.Cess;
        DetailedGSTLedgerEntryInfo."Component Calc. Type" := DetailedGSTEntryBuffer."Component Calc. Type";
        DetailedGSTLedgerEntryInfo."Cess Amount Per Unit Factor" := DetailedGSTEntryBuffer."Cess Amt Per Unit Factor (LCY)";
        DetailedGSTLedgerEntryInfo."Cess UOM" := DetailedGSTEntryBuffer."Cess UOM";
        DetailedGSTLedgerEntryInfo."Cess Factor Quantity" := DetailedGSTEntryBuffer."Cess Factor Quantity";
        DetailedGSTLedgerEntryInfo.UOM := DetailedGSTEntryBuffer.UOM;
        DetailedGSTLedgerEntryInfo."From Location Code" := TransferHeader."Transfer-from Code";
        DetailedGSTLedgerEntryInfo."To Location Code" := TransferHeader."Transfer-to Code";
        if DocTransferType = DocTransferType::"Transfer Shipment" then begin
            DetailedGSTLedgerEntryInfo."Location ARN No." := Location."Location ARN No.";
            DetailedGSTLedgerEntryInfo."Location State Code" := Location."State Code";
            DetailedGSTLedgerEntryInfo."Buyer/Seller State Code" := Location2."State Code";
            DetailedGSTLedgerEntryInfo."Shipping Address State Code" := '';
            DetailedGSTLedgerEntryInfo."Original Doc. Type" := DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Transfer Shipment";
            DetailedGSTLedgerEntryInfo."Sales Invoice Type" := "Sales Invoice Type"::Taxable;
        end else begin
            DetailedGSTLedgerEntryInfo."Location ARN No." := Location2."Location ARN No.";
            DetailedGSTLedgerEntryInfo."Location State Code" := Location2."State Code";
            DetailedGSTLedgerEntryInfo."Buyer/Seller State Code" := Location."State Code";
            DetailedGSTLedgerEntryInfo."Shipping Address State Code" := '';
            DetailedGSTLedgerEntryInfo."Original Doc. Type" := DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Transfer Receipt";
            if Location."Bonded warehouse" then begin
                DetailedGSTLedgerEntryInfo."Buyer/Seller State Code" := '';
                DetailedGSTLedgerEntryInfo."Bill of Entry No." := TransferHeader."Bill of Entry No.";
                DetailedGSTLedgerEntryInfo."Bill of Entry Date" := TransferHeader."Bill of Entry Date";
            end;
        end;
        DetailedGSTLedgerEntryInfo.Insert(true);
    end;

    local procedure FillDetailLedgBufferTransfer(DocNo: Code[20])
    var
        TransferLine: Record "Transfer Line";
        TransferHeader: Record "Transfer Header";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        GSTGroup: Record "GST Group";
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
        Item: Record Item;
        Sign: Integer;
        DocumentType: Enum "Document Type Enum";
        TransactionType: Enum "Transaction Type Enum";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        GSTSetup.TestField("Cess Tax Type");
        TransferHeader.Get(DocNo);
        GeneralLedgerSetup.Get();
        Sign := GSTBaseValidation.GetSignTransfer(DocumentType::Quote, TransactionType::"Transfer");

        TransferLine.Reset();
        TransferLine.SetRange("Document No.", DocNo);
        if TransferLine.FindSet() then
            repeat
                if TransferLine."Item No." <> '' then begin
                    TransferLine.TestField(Quantity);
                    Item.Get(TransferLine."Item No.");
                    TaxTransactionValue.Reset();
                    TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                    TaxTransactionValue.SetFilter("Tax Type", '%1|%2', GSTSetup."GST Tax Type", GSTSetup."Cess Tax Type");
                    TaxTransactionValue.SetRange("Tax Record ID", TransferLine.RecordId);
                    TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
                    TaxTransactionValue.SetFilter(Amount, '<>%1', 0);
                    if TaxTransactionValue.FindSet() then
                        repeat
                            DetailedGSTEntryBuffer.Init();
                            DetailedGSTEntryBuffer."Entry No." := 0;
                            DetailedGSTEntryBuffer."Document Type" := DetailedGSTEntryBuffer."Document Type"::Quote;
                            DetailedGSTEntryBuffer."Document No." := TransferHeader."No.";
                            DetailedGSTEntryBuffer."Posting Date" := TransferHeader."Posting Date";
                            DetailedGSTEntryBuffer."Transaction Type" := DetailedGSTEntryBuffer."Transaction Type"::transfer;
                            DetailedGSTEntryBuffer.Type := DetailedGSTEntryBuffer.Type::Item;
                            DetailedGSTEntryBuffer.UOM := Item."Base Unit of Measure";
                            DetailedGSTEntryBuffer."No." := TransferLine."Item No.";
                            DetailedGSTEntryBuffer."Source No." := '';
                            DetailedGSTEntryBuffer.Quantity := TransferLine.Quantity * Sign;
                            DetailedGSTEntryBuffer."HSN/SAC Code" := TransferLine."HSN/SAC Code";
                            DetailedGSTEntryBuffer.Exempted := TransferLine.Exempted;
                            DetailedGSTEntryBuffer."Location Code" := TransferHeader."Transfer-from Code";
                            DetailedGSTEntryBuffer."Line No." := TransferLine."Line No.";
                            DetailedGSTEntryBuffer."Source Type" := "Source Type"::" ";
                            DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := Sign * TaxTransactionValue.Amount;
                            DetailedGSTEntryBuffer."GST Base Amount" := Sign * TransferLine.Amount;
                            DetailedGSTEntryBuffer."GST %" := TaxTransactionValue.Percent;
                            DetailedGSTEntryBuffer."Currency Factor" := 1;
                            DetailedGSTEntryBuffer."GST Amount" := Sign * TaxTransactionValue.Amount;
                            DetailedGSTEntryBuffer."Custom Duty Amount" := TransferLine."Custom Duty Amount";
                            DetailedGSTEntryBuffer."GST Assessable Value" := TransferLine."GST Assessable Value";
                            if TransferLine."GST Credit" = TransferLine."GST Credit"::"Non-Availment" then begin
                                DetailedGSTEntryBuffer."Amount Loaded on Item" := Sign * TaxTransactionValue.Amount;
                                DetailedGSTEntryBuffer."Non-Availment" := true;
                            end else
                                DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := Sign * TaxTransactionValue.Amount;

                            if TaxTransactionValue."Tax Type" = GSTSetup."Cess Tax Type" then
                                DetailedGSTEntryBuffer."GST Component Code" := 'CESS'
                            else
                                DetailedGSTEntryBuffer."GST Component Code" := GetGSTComponent(TaxTransactionValue."Value ID");
                            DetailedGSTEntryBuffer."GST Group Code" := TransferLine."GST Group Code";
                            if GSTGroup.Get(TransferLine."GST Group Code") and (GSTSetup."Cess Tax Type" = TaxTransactionValue."Tax Type") then
                                DetailedGSTEntryBuffer."Component Calc. Type" := GSTGroup."Component Calc. Type";
                            GSTBaseValidation.GetTaxComponentRoundingPrecision(DetailedGSTEntryBuffer, TaxTransactionValue);
                            DetailedGSTEntryBuffer.Insert(true);
                        until TaxTransactionValue.Next() = 0;
                end;
            until TransferLine.Next() = 0;
    end;

    local procedure GetGSTComponent(ComponentID: Integer): Code[30]
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        GSTSetup.TestField("Cess Tax Type");
        TaxComponent.SetFilter("Tax Type", '%1|%2', GSTSetup."GST Tax Type", GSTSetup."Cess Tax Type");
        TaxComponent.SetRange(Id, ComponentID);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Name);
    end;

    local procedure GetGSTAmount(TaxRecordId: RecordID): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Value Type", "Tax Type", Percent);
        TaxTransactionValue.SetRange("Tax Record ID", TaxRecordId);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        if GSTSetup."Cess Tax Type" <> '' then
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type", GSTSetup."Cess Tax Type")
        else
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.CalcSums(Amount);

        exit(TaxTransactionValue.Amount);
    end;

    local procedure FillTransferBuffer(TransferLine: Record "Transfer Line")
    var
        BondedLocation: Record Location;
        TransferHeader: Record "Transfer Header";
        DocTransactionType: Enum "Transaction Type Enum";
        DocumentType: Enum "Document Type Enum";
    begin
        if (TransferLine."GST Group Code" = '') or (TransferLine."HSN/SAC Code" = '') or (TransferLine."Qty. to Ship" = 0) then
            exit;

        Clear(TempTransferBufferStage);
        TransferHeader.Get(TransferLine."Document No.");
        BondedLocation.Get(TransferHeader."Transfer-from Code");
        TempTransferBufferStage."System-Created Entry" := true;
        TempTransferBufferStage."Gen. Prod. Posting Group" := TransferLine."Gen. Prod. Posting Group";
        TempTransferBufferStage."Global Dimension 1 Code" := TransferLine."Shortcut Dimension 1 Code";
        TempTransferBufferStage."Global Dimension 2 Code" := TransferLine."Shortcut Dimension 2 Code";
        TempTransferBufferStage."Dimension Set ID" := TransferLine."Dimension Set ID";
        TempTransferBufferStage."Inventory Posting Group" := TransferLine."Inventory Posting Group";
        TempTransferBufferStage."Item No." := TransferLine."Item No.";
        if not BondedLocation."Bonded warehouse" then begin
            TempTransferBufferStage.Amount := Round(
                RoundTotalGSTAmountQtyFactor(
                    DocTransactionType::Transfer,
                    DocumentType::Quote,
                    TransferLine."Document No.",
                    TransferLine."Line No.",
                    TransferLine."Qty. to Ship" / TransferLine.Quantity,
                    '',
                    false)
            );
            TempTransferBufferStage."GST Amount" := Round(
                RoundTotalGSTAmountQtyFactor(
                    DocTransactionType::Transfer,
                    DocumentType::Quote,
                    TransferLine."Document No.",
                    TransferLine."Line No.",
                    TransferLine."Qty. to Ship" / TransferLine.Quantity,
                    '',
                    false)
            );
        end;

        TempTransferBufferStage.Quantity := TransferLine."Qty. to Ship";
        TempTransferBufferStage."Amount Loaded on Inventory" := Round(TransferLine."Amount Added to Inventory" * TransferLine."Qty. to Ship" / TransferLine.Quantity);
        TempTransferBufferStage."Charges Amount" := Round(TransferLine."Charges to Transfer" * TransferLine."Qty. to Ship" / TransferLine.Quantity);
        TempTransferBufferStage."Excise Amount" := Round(TransferLine."Qty. to Ship" * (TransferLine."Transfer Price" - -(TransferCost / TransferQuantity)));
        TempTransferBufferStage.Amount := TempTransferBufferStage.Amount + TempTransferBufferStage."Excise Amount";
        UpdTransferBuffer(TransferLine, TransferLine."Line No.");
    end;

    local procedure UpdTransferBuffer(TransLine: Record "Transfer Line"; SortingNo: Integer)
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        TempTransferBufferStage."Dimension Set ID" := TransLine."Dimension Set ID";
        DimensionManagement.UpdateGlobalDimFromDimSetID(
            TempTransferBufferStage."Dimension Set ID",
            TempTransferBufferStage."Global Dimension 1 Code",
            TempTransferBufferStage."Global Dimension 2 Code");

        ApplyFilterOnTempTransferBufferFinal(TempTransferBufferFinal, TempTransferBufferStage);
        if TempTransferBufferFinal.FindFirst() then begin
            TempTransferBufferFinal."Excise Amount" := TempTransferBufferFinal."Excise Amount" + TempTransferBufferStage."Excise Amount";
            TempTransferBufferFinal.Amount := TempTransferBufferFinal.Amount + TempTransferBufferStage.Amount;
            TempTransferBufferFinal."GST Amount" := TempTransferBufferFinal."GST Amount" + TempTransferBufferStage."GST Amount";
            TempTransferBufferFinal.Quantity := TempTransferBufferFinal.Quantity + TempTransferBufferStage.Quantity;
            TempTransferBufferFinal."Amount Loaded on Inventory" := TempTransferBufferFinal."Amount Loaded on Inventory" + TempTransferBufferStage."Amount Loaded on Inventory";
            TempTransferBufferFinal."Charges Amount" := TempTransferBufferFinal."Charges Amount" + TempTransferBufferStage."Charges Amount";
            if not TempTransferBufferStage."System-Created Entry" then
                TempTransferBufferFinal."System-Created Entry" := false;

            TempTransferBufferFinal.Modify();
        end else begin
            TempTransferBufferFinal := TempTransferBufferStage;
            TempTransferBufferFinal."Sorting No." := SortingNo;
            TempTransferBufferFinal.Insert();
        end;
    end;

    local procedure ApplyFilterOnTempTransferBufferFinal(
        var TempTransferBufferFinal: Record "Transfer Buffer";
        var TempTransferBufferStage: Record "Transfer Buffer")
    begin
        TempTransferBufferFinal.SetRange(Type, TempTransferBufferStage.Type);
        TempTransferBufferFinal.SetRange("G/L Account", TempTransferBufferStage."G/L Account");
        TempTransferBufferFinal.SetRange("Gen. Bus. Posting Group", TempTransferBufferStage."Gen. Bus. Posting Group");
        TempTransferBufferFinal.SetRange("Gen. Prod. Posting Group", TempTransferBufferStage."Gen. Prod. Posting Group");
        TempTransferBufferFinal.SetRange("Inventory Posting Group", TempTransferBufferStage."Inventory Posting Group");
        TempTransferBufferFinal.SetRange("Item No.", TempTransferBufferStage."Item No.");
    end;

    local procedure FillGSTPostingBuffer(TransferLine: Record "Transfer Line")
    var
        Location: Record Location;
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        TransferHeader: Record "Transfer Header";
        QFactor: Decimal;
        GSTStateCode: Code[10];
    begin
        TransferHeader.Get(TransferLine."Document No.");
        if (not Location.Get(TransferHeader."Transfer-from Code")) or (Location."Bonded warehouse") then
            exit;

        Location.TestField("State Code");
        GSTStateCode := Location."State Code";

        DetailedGSTEntryBuffer.Reset();
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::Transfer);
        DetailedGSTEntryBuffer.SetRange("Document Type", 0);
        DetailedGSTEntryBuffer.SetRange("Document No.", TransferLine."Document No.");
        DetailedGSTEntryBuffer.SetRange("Line No.", TransferLine."Line No.");
        DetailedGSTEntryBuffer.SetFilter("GST Base Amount", '<>%1', 0);
        if DetailedGSTEntryBuffer.FindSet() then
            repeat
                TempGSTPostingBufferStage.Type := TempGSTPostingBufferStage.Type::Item;
                TempGSTPostingBufferStage."Global Dimension 1 Code" := TransferLine."Shortcut Dimension 1 Code";
                TempGSTPostingBufferStage."Global Dimension 2 Code" := TransferLine."Shortcut Dimension 2 Code";
                TempGSTPostingBufferStage."Gen. Prod. Posting Group" := TransferLine."Gen. Prod. Posting Group";
                TempGSTPostingBufferStage."GST Group Code" := TransferLine."GST Group Code";
                QFactor := Abs(TransferLine."Qty. to Ship" / TransferLine.Quantity);
                TempGSTPostingBufferStage."GST Base Amount" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code", (QFactor * DetailedGSTEntryBuffer."GST Base Amount"));
                TempGSTPostingBufferStage."GST Amount" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code", (QFactor * DetailedGSTEntryBuffer."GST Amount"));
                TempGSTPostingBufferStage."GST %" := DetailedGSTEntryBuffer."GST %";
                TempGSTPostingBufferStage."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                if TempGSTPostingBufferStage."GST Amount" <> 0 then
                    TempGSTPostingBufferStage."Account No." := GetGSTPayableAccountNo(GSTStateCode, DetailedGSTEntryBuffer."GST Component Code");
                UpdateGSTPostingBuffer(TransferLine);
            until DetailedGSTEntryBuffer.Next() = 0;
    end;

    local procedure UpdateGSTPostingBuffer(TransferLine: Record "Transfer Line")
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        TempGSTPostingBufferStage."Dimension Set ID" := TransferLine."Dimension Set ID";
        DimensionManagement.UpdateGlobalDimFromDimSetID(
            TempGSTPostingBufferStage."Dimension Set ID",
            TempGSTPostingBufferStage."Global Dimension 1 Code",
            TempGSTPostingBufferStage."Global Dimension 2 Code");

        ApplyFilterOnTempGSTPostingBufferFinal(TempGSTPostingBufferFinal, TempGSTPostingBufferStage);
        if TempGSTPostingBufferFinal.FindFirst() then begin
            TempGSTPostingBufferFinal."GST Base Amount" += TempGSTPostingBufferStage."GST Base Amount";
            TempGSTPostingBufferFinal."GST Amount" += TempGSTPostingBufferStage."GST Amount";
            TempGSTPostingBufferFinal."Interim Amount" += TempGSTPostingBufferStage."Interim Amount";
            TempGSTPostingBufferFinal.Modify();
        end else begin
            TempGSTPostingBufferFinal := TempGSTPostingBufferStage;
            TempGSTPostingBufferFinal.Insert();
        end;
    end;

    local procedure ApplyFilterOnTempGSTPostingBufferFinal(
            var TempGSTPostingBufferFinal: Record "GST Posting Buffer";
            var TempGSTPostingBufferStage: Record "GST Posting Buffer")
    begin
        TempGSTPostingBufferFinal.SetRange(Type, TempGSTPostingBufferStage.Type);
        TempGSTPostingBufferFinal.SetRange("Transaction Type", TempGSTPostingBufferStage."Transaction Type");
        TempGSTPostingBufferFinal.SetRange("Global Dimension 1 Code", TempGSTPostingBufferStage."Global Dimension 1 Code");
        TempGSTPostingBufferFinal.SetRange("Global Dimension 2 Code", TempGSTPostingBufferStage."Global Dimension 2 Code");
        TempGSTPostingBufferFinal.SetRange("Dimension Set ID", TempGSTPostingBufferStage."Dimension Set ID");
        TempGSTPostingBufferFinal.SetRange("Account No.", TempGSTPostingBufferStage."Account No.");
        TempGSTPostingBufferFinal.SetRange("Gen. Bus. Posting Group", TempGSTPostingBufferStage."Gen. Bus. Posting Group");
        TempGSTPostingBufferFinal.SetRange("Gen. Prod. Posting Group", TempGSTPostingBufferStage."Gen. Prod. Posting Group");
    end;

    local procedure GetGSTPayableAccountNo(LocationCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Reset();
        GSTPostingSetup.SetRange("State Code", LocationCode);
        GSTPostingSetup.SetRange("Component ID", GSTComponentID(GSTComponentCode));
        GSTPostingSetup.FindFirst();
        exit(GSTPostingSetup."Payable Account")
    end;


    local procedure RoundTotalGSTAmountQtyFactor(
        TransactionType: Enum "Transaction Type Enum";
        DocumentType: Enum "Document Type Enum";
        DocumentNo: Code[20];
        LineNo: Integer;
        QtyFactor: Decimal;
        CurrencyCode: Code[10];
        GSTInvoiceRouding: Boolean): Decimal
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        TotalGSTAmount: Decimal;
        Sign: Integer;
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", TransactionType);
        DetailedGSTEntryBuffer.SetRange("Document Type", DocumentType);
        DetailedGSTEntryBuffer.SetRange("Document No.", DocumentNo);
        DetailedGSTEntryBuffer.SetRange("Line No.", LineNo);
        if DetailedGSTEntryBuffer.FindSet() then
            repeat
                if DetailedGSTEntryBuffer."Amount Loaded on Item" <> 0 then
                    TotalGSTAmount += DetailedGSTEntryBuffer."Amount Loaded on Item" * QtyFactor
                else
                    if DetailedGSTEntryBuffer."GST Input/Output Credit Amount" <> 0 then
                        TotalGSTAmount += DetailedGSTEntryBuffer."GST Input/Output Credit Amount" * QtyFactor;

                if CurrencyCode = '' then
                    if GSTInvoiceRouding then
                        TotalGSTAmount := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code", TotalGSTAmount)
                    else
                        TotalGSTAmount := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code", TotalGSTAmount);

                if (CurrencyCode <> '') and GSTInvoiceRouding then
                    TotalGSTAmount := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code", TotalGSTAmount);

            until DetailedGSTEntryBuffer.Next() = 0;

        Sign := GSTBaseValidation.GetSignTransfer(DocumentType, TransactionType);
        exit(TotalGSTAmount * Sign);
    end;

    local procedure PostTransLineToGenJnlLine(TransferHeader: Record "Transfer Header"; TransferShptNo: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        DocTransferType: Enum "Doc Transfer Type";
        IsHandled: Boolean;
    begin
        SourceCodeSetup.Get();
        OnBeforePostTransLineToGenJnlLine(GenJournalLine, TempGSTPostingBufferFinal, TempTransferBufferStage, TransferHeader, TransferShptNo, IsHandled);
        if IsHandled then
            exit;

        GenJournalLine.Init();
        GenJournalLine."Posting Date" := TransferHeader."Posting Date";
        GenJournalLine.Description := StrSubstNo(TransferShipmentNoLbl, TransferShptNo);
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
        GenJournalLine."Document No." := TransferShptNo;
        GenJournalLine."External Document No." := TransferHeader."No.";
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        if TempGSTPostingBufferFinal."GST Amount" <> 0 then begin
            GenJournalLine.Validate(Amount, Round(TempGSTPostingBufferFinal."GST Amount"));
            GenJournalLine."Account No." := TempGSTPostingBufferFinal."Account No.";
        end;

        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."GST Group Code" := TempGSTPostingBufferFinal."GST Group Code";
        GenJournalLine."GST Component Code" := TempGSTPostingBufferFinal."GST Component Code";
        GenJournalLine."System-Created Entry" := TempTransferBufferStage."System-Created Entry";
        GenJournalLine."Gen. Bus. Posting Group" := TempGSTPostingBufferFinal."Gen. Bus. Posting Group";
        GenJournalLine."Gen. Prod. Posting Group" := TempGSTPostingBufferFinal."Gen. Prod. Posting Group";
        GenJournalLine."Shortcut Dimension 1 Code" := TempGSTPostingBufferFinal."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TempGSTPostingBufferFinal."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TempGSTPostingBufferFinal."Dimension Set ID";
        GenJournalLine."Location Code" := TransferHeader."Transfer-from Code";
        GenJournalLine."Source Code" := SourceCodeSetup.Transfer;

        OnBeforeRunGenJnlPostTransferLine(GenJournalLine, TempGSTPostingBufferFinal, TempTransferBufferStage, TransferHeader, TransferShptNo);
        RunGenJnlPostLine(GenJournalLine);
        OnAfterRunGenJnlPostLineOnBeforeInsertGSTLedgerEntryTransfer(GenJournalLine, TempGSTPostingBufferFinal, TransferHeader, GenJnlPostLine);

        InsertGSTLedgerEntryTransfer(
          TempGSTPostingBufferFinal,
          TransferHeader,
          GenJnlPostLine.GetNextTransactionNo(),
          GenJournalLine."Document No.",
          SourceCodeSetup.Transfer,
          DocTransferType::"Transfer Shipment");
    end;

    local procedure UpdateDetailedGSTLedgerEntryTransfer(
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DocumentNo: Code[20];
        LineNo: Integer;
        TransactionNo: Integer;
        QtyBase: Decimal;
        QtyShip: Decimal;
        DocTransferType: Enum "Doc Transfer Type")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::Transfer);
        DetailedGSTEntryBuffer.SetRange("Document Type", DetailedGSTEntryBuffer."Document Type"::Quote);
        DetailedGSTEntryBuffer.SetRange("Document No.", DocumentNo);
        DetailedGSTEntryBuffer.SetRange("Line No.", LineNo);
        DetailedGSTEntryBuffer.SetRange("GST Component Code", DetailedGSTLedgerEntry."GST Component Code");
        if DetailedGSTEntryBuffer.FindFirst() then begin
            DetailedGSTLedgerEntry.Type := DetailedGSTEntryBuffer.Type;
            DetailedGSTLedgerEntry."No." := DetailedGSTEntryBuffer."No.";
            DetailedGSTLedgerEntry."Product Type" := DetailedGSTLedgerEntry."Product Type"::Item;
            DetailedGSTLedgerEntry."HSN/SAC Code" := DetailedGSTEntryBuffer."HSN/SAC Code";
            DetailedGSTLedgerEntry."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
            DetailedGSTLedgerEntry."GST Group Code" := DetailedGSTEntryBuffer."GST Group Code";
            DetailedGSTLedgerEntry."Document Line No." := DetailedGSTEntryBuffer."Line No.";
            if DetailedGSTEntryBuffer."GST Assessable Value" <> 0 then begin
                DetailedGSTLedgerEntry."GST Base Amount" := -GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(
                                                                                DetailedGSTEntryBuffer."GST Component Code", (
                                                                                    DetailedGSTEntryBuffer."GST Assessable Value"
                                                                                    + DetailedGSTEntryBuffer."Custom Duty Amount"));
                DetailedGSTLedgerEntry."GST Amount" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code",
                                                                                                                (DetailedGSTEntryBuffer."GST Amount"));
            end else begin
                DetailedGSTLedgerEntry."GST Base Amount" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code",
                                                                                                            (DetailedGSTEntryBuffer."GST Base Amount" * QtyShip / QtyBase));
                DetailedGSTLedgerEntry."GST Amount" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code",
                                                                                                            (DetailedGSTEntryBuffer."GST Amount" * QtyShip / QtyBase));
            end;

            DetailedGSTLedgerEntry."Remaining Base Amount" := 0;
            DetailedGSTLedgerEntry."Remaining GST Amount" := 0;
            DetailedGSTLedgerEntry."GST %" := DetailedGSTEntryBuffer."GST %";
            if DocTransferType = DocTransferType::"Transfer Shipment" then begin
                DetailedGSTLedgerEntry.Quantity := -QtyShip;
                DetailedGSTLedgerEntry."Remaining Quantity" := -QtyShip;
            end else begin
                DetailedGSTLedgerEntry.Quantity := QtyShip;
                DetailedGSTLedgerEntry."Remaining Quantity" := QtyShip;
            end;

            if DocTransferType = DocTransferType::"Transfer Receipt" then
                if DetailedGSTEntryBuffer."GST Assessable Value" <> 0 then
                    DetailedGSTLedgerEntry."Amount Loaded on Item" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code",
                                                                                                                            DetailedGSTEntryBuffer."Amount Loaded on Item")
                else
                    DetailedGSTLedgerEntry."Amount Loaded on Item" := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code",
                                                                                                    (DetailedGSTEntryBuffer."Amount Loaded on Item" * QtyShip / QtyBase))
            else
                DetailedGSTLedgerEntry."Amount Loaded on Item" := 0;

            if DocTransferType = DocTransferType::"Transfer Receipt" then begin
                if DetailedGSTLedgerEntry."Amount Loaded on Item" <> 0 then
                    DetailedGSTLedgerEntry."GST Credit" := DetailedGSTLedgerEntry."GST Credit"::"Non-Availment"
                else
                    DetailedGSTLedgerEntry."GST Credit" := DetailedGSTLedgerEntry."GST Credit"::Availment;

                DetailedGSTLedgerEntry."Credit Availed" := GetReceivableApplicable(
                DetailedGSTLedgerEntry."GST Vendor Type",
                DetailedGSTLedgerEntry."GST Group Type",
                DetailedGSTLedgerEntry."GST Credit", false, false);
            end;

            if DocTransferType = DocTransferType::"Transfer Receipt" then
                ReverseDetailedGSTEntryQtyAmt(DetailedGSTLedgerEntry);

            DetailedGSTLedgerEntry."GST Rounding Type" := DetailedGSTEntryBuffer."GST Rounding Type";
            DetailedGSTLedgerEntry."GST Rounding Precision" := DetailedGSTEntryBuffer."GST Rounding Precision";
            DetailedGSTLedgerEntry."GST Inv. Rounding Type" := DetailedGSTEntryBuffer."GST Inv. Rounding Type";
            DetailedGSTLedgerEntry."GST Inv. Rounding Precision" := DetailedGSTEntryBuffer."GST Inv. Rounding Precision";
            DetailedGSTLedgerEntry."Transaction No." := TransactionNo;
            if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::"Non-Availment" then
                DetailedGSTLedgerEntry."Eligibility for ITC" := DetailedGSTLedgerEntry."Eligibility for ITC"::Ineligible
            else
                if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::Availment then
                    if DetailedGSTLedgerEntry."GST Group Type" = DetailedGSTLedgerEntry."GST Group Type"::Service then
                        DetailedGSTLedgerEntry."Eligibility for ITC" := DetailedGSTLedgerEntry."Eligibility for ITC"::"Input Services"
                    else
                        if DetailedGSTLedgerEntry.Type = DetailedGSTLedgerEntry.Type::"Fixed Asset" then
                            DetailedGSTLedgerEntry."Eligibility for ITC" := DetailedGSTLedgerEntry."Eligibility for ITC"::"Capital goods"
                        else
                            DetailedGSTLedgerEntry."Eligibility for ITC" := DetailedGSTLedgerEntry."Eligibility for ITC"::Inputs;
        end;
    end;

    local procedure ReverseDetailedGSTEntryQtyAmt(var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry")
    begin
        DetailedGSTLedgerEntry."GST Base Amount" := -DetailedGSTLedgerEntry."GST Base Amount";
        DetailedGSTLedgerEntry."GST Amount" := -DetailedGSTLedgerEntry."GST Amount";
        DetailedGSTLedgerEntry."Amount Loaded on Item" := -DetailedGSTLedgerEntry."Amount Loaded on Item";
    end;

    local procedure GetReceivableApplicable(
        GSTVendorType: Enum "GST Vendor Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCredit: Enum "GST Credit";
        AssociatedEnterprises: Boolean;
        ReverseCharge: Boolean): Boolean
    begin
        if GSTCredit = GSTCredit::Availment then
            case GSTVendorType of
                GSTVendorType::Registered:
                    begin
                        if ReverseCharge then
                            exit(false);

                        exit(true);
                    end;
                GSTVendorType::Unregistered:
                    if GSTGroupType = GSTGroupType::Goods then
                        exit(true);
                GSTVendorType::Import, GSTVendorType::SEZ:
                    begin
                        if (GSTGroupType = GSTGroupType::Service) and not ReverseCharge then
                            exit(true);

                        if GSTGroupType = GSTGroupType::Goods then
                            exit(true);

                        exit(AssociatedEnterprises = true);
                    end;
            end;
    end;

    local procedure GetFromEntryNo(DocumentNo: Code[20]; LineNo: Integer; OrignalDocType: Enum "Original Doc Type"): Integer
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("Document Line No.", LineNo);
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        if DetailedGSTLedgerEntry.FindFirst() then
            if DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.") then
                if DetailedGSTLedgerEntryInfo."Original Doc. Type" = OrignalDocType then
                    exit(DetailedGSTLedgerEntryInfo."Entry No.");

        exit(1);
    end;

    local procedure GetToEntryNo(DocumentNO: Code[20]; LineNo: Integer; OrignalDocType: Enum "Original Doc Type"): Integer
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNO);
        DetailedGSTLedgerEntry.SetRange("Document Line No.", LineNo);
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        if DetailedGSTLedgerEntry.FindLast() then
            if DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.") then
                if DetailedGSTLedgerEntryInfo."Original Doc. Type" = OrignalDocType then
                    exit(DetailedGSTLedgerEntryInfo."Entry No.");

        exit(1);
    end;

    local procedure RunGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure GETGSTJurisdictionType(TransferHeader: Record "Transfer Header"): Enum "GST Jurisdiction Type"
    var
        Location: Record Location;
        Location2: Record Location;
        GSTJurisdictionType: Enum "GST Jurisdiction Type";
    begin
        Location.Get(TransferHeader."Transfer-from Code");
        Location2.Get(TransferHeader."Transfer-to Code");
        if Location."State Code" <> Location2."State Code" then
            exit(GSTJurisdictionType::Interstate)
        else
            exit(GSTJurisdictionType::Intrastate);
    end;

    local procedure GetTransferShipmentPostingNoSeries(var TransferHeader: Record "Transfer Header"): Code[20]
    var
        PostingNoSeries: Record "Posting No. Series";
        NoSeriesCode: Code[20];
    begin
        PostingNoSeries.SetRange("Table Id", Database::"Transfer Header");
        NoSeriesCode := LoopPostingNoSeries(PostingNoSeries, TransferHeader, PostingNoSeries."Document Type"::"Transfer Shipment Header");
        exit(NoSeriesCode);
    end;

    local procedure RecordViewFound(Record: Variant; Filters: Text) Found: Boolean;
    var
        Field: Record Field;
        DuplicateRecRef: RecordRef;
        TempRecRef: RecordRef;
        FieldRef: FieldRef;
        TempFieldRef: FieldRef;
    begin
        DuplicateRecRef.GetTable(Record);
        Clear(TempRecRef);
        TempRecRef.Open(DuplicateRecRef.Number(), true);
        Field.SetRange(TableNo, DuplicateRecRef.Number());
        if Field.FindSet() then
            repeat
                FieldRef := DuplicateRecRef.Field(Field."No.");
                TempFieldRef := TempRecRef.Field(Field."No.");
                TempFieldRef.Value := FieldRef.Value();
            until Field.Next() = 0;

        TempRecRef.Insert();
        Found := true;
        if Filters = '' then
            exit;

        TempRecRef.SetView(Filters);
        Found := TempRecRef.Find();
    end;

    local procedure GetRecordView(var PostingNoSeries: Record "Posting No. Series") Filters: Text;
    var
        ConditionInStream: InStream;
    begin
        PostingNoSeries.CalcFields(Condition);
        PostingNoSeries.Condition.CreateInStream(ConditionInStream);
        ConditionInStream.Read(Filters);
    end;

    local procedure ClearBuffers()
    begin
        ClearAll();
        TempTransferBufferStage.DeleteAll();
        TempTransferBufferFinal.DeleteAll();
        TempGSTPostingBufferStage.DeleteAll();
        TempGSTPostingBufferFinal.DeleteAll();
    end;

    local procedure FillDetailedGSTLedgerEntryShipment(
        Var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        Location: Record Location;
        Location2: Record Location;
        TransferHeader: Record "Transfer Header")
    begin
        DetailedGSTLedgerEntry."Location Code" := Location.Code;
        DetailedGSTLedgerEntry."Location  Reg. No." := Location."GST Registration No.";
        DetailedGSTLedgerEntry."Buyer/Seller Reg. No." := Location2."GST Registration No.";
        DetailedGSTLedgerEntry."External Document No." := TransferHeader."No.";
        DetailedGSTLedgerEntry."GST Customer Type" := "GST Customer Type"::Registered;
        DetailedGSTLedgerEntry."Liable to Pay" := true;
    end;

    local procedure FillDetailedGSTLedgerEntryReceipt(
        Var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        Location: Record Location;
        Location2: Record Location;
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line")
    begin
        DetailedGSTLedgerEntry."Location Code" := Location2.Code;
        DetailedGSTLedgerEntry."Location  Reg. No." := Location2."GST Registration No.";
        DetailedGSTLedgerEntry."Buyer/Seller Reg. No." := Location."GST Registration No.";
        DetailedGSTLedgerEntry."External Document No." := TransferHeader."Last Shipment No.";
        DetailedGSTLedgerEntry."GST VEndor Type" := "GST VEndor Type"::Registered;
        if Location."Bonded warehouse" then begin
            DetailedGSTLedgerEntry."GST VEndor Type" := "GST VEndor Type"::Import;
            DetailedGSTLedgerEntry."Credit Availed" := true;
            DetailedGSTLedgerEntry."Reverse Charge" := true;
            DetailedGSTLedgerEntry."Buyer/Seller Reg. No." := '';
            DetailedGSTLedgerEntry."Source Type" := "Source Type"::VEndor;
            DetailedGSTLedgerEntry."Source No." := TransferHeader."VEndor No.";
            DetailedGSTLedgerEntry."GST Assessable Value" := TransferLine."GST Assessable Value";
            DetailedGSTLedgerEntry."Custom Duty Amount" := TransferLine."Custom Duty Amount";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure CopyInfotoShipmentLine(var TransferShipmentLine: Record "Transfer Shipment Line";
        TransferLine: Record "Transfer Line")
    var
        Location: Record Location;
    begin
        if not Location.Get(TransferLine."Transfer-from Code") then
            exit;

        if not Location."Bonded warehouse" then begin
            TransferShipmentLine."GST Group Code" := TransferLine."GST Group Code";
            TransferShipmentLine."GST Credit" := TransferLine."GST Credit";
            TransferShipmentLine."HSN/SAC Code" := TransferLine."HSN/SAC Code";
            TransferShipmentLine.Exempted := TransferLine.Exempted;
        end;

        TransferShipmentLine."Unit Price" := TransferLine."Transfer Price";
        TransferShipmentLine.Amount := TransferLine.Amount * TransferLine."Qty. to Ship" / TransferLine.Quantity;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeGenNextNo', '', false, false)]
    local procedure GetPostingNoSeries(TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        NoSeries: Codeunit "No. Series";
        NoSeriesCode: Code[20];
    begin
        NoSeriesCode := GetTransferShipmentPostingNoSeries(TransferHeader);
        if NoSeriesCode <> '' then begin
            TransferShipmentHeader."No. Series" := NoSeriesCode;
            TransferShipmentHeader."No." := NoSeries.GetNextNo(TransferShipmentHeader."No. Series", TransferHeader."Posting Date");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeTransferOrderPostShipment', '', false, false)]
    local procedure OnBeforePostShipment(var TransferHeader: Record "Transfer Header")
    begin
        GSTBaseValidation.CheckGSTAccountingPeriod(TransferHeader."Posting Date", false);
        ClearBuffers();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterInsertTransShptLine', '', false, false)]
    local procedure InsertTransferBuffer(TransLine: Record "Transfer Line")
    begin
        FillTransferBuffer(TransLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterInsertTransShptLine', '', false, false)]
    local procedure InsertDetailedGSTEntry(TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")
    var
        TransferHeader: Record "Transfer Header";
        Location: Record Location;
        DocTransferType: Enum "Doc Transfer Type";
    begin
        TransferHeader.Get(TransLine."Document No.");
        Location.Get(TransferHeader."Transfer-from Code");
        if not Location."Bonded warehouse" then
            InsertDetailedGSTLedgEntryTransfer(TransLine, TransferHeader, TransShptLine."Document No.", GenJnlPostLine.GetNextTransactionNo(), DocTransferType::"Transfer Shipment");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnRunOnBeforeCommit', '', false, false)]
    local procedure PostGLEntries(var TransferHeader: Record "Transfer Header"; TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        TransferLine: Record "Transfer Line";
        IsHandled: Boolean;
    begin
        OnBeforePostGLEntries(TempTransferBufferFinal, TempGSTPostingBufferFinal, TransferHeader, TransferShipmentHeader, TransferLine, InventoryPostingSetup, IsHandled);
        if IsHandled then
            exit;

        // Post GST to G/L entries from GST posting buffer.. GST Sales
        TempGSTPostingBufferFinal.Reset();
        TempGSTPostingBufferFinal.SetCurrentKey(
            "Transaction Type",
            Type,
            "Gen. Bus. Posting Group",
            "Gen. Prod. Posting Group",
            "GST Component Code",
            "GST Group Type",
            "Account No.",
            "Dimension Set ID",
            "GST Reverse Charge",
            Availment,
            "Normal Payment",
            "Forex Fluctuation",
            "Document Line No.");
        TempGSTPostingBufferFinal.SetAscending("Document Line No.", false);
        OnFindTempGSTPostingBufferFinalForTransfer(TempGSTPostingBufferFinal, TempTransferBufferFinal, TransferHeader, TransferShipmentHeader);
        if TempGSTPostingBufferFinal.FindSet() then
            repeat
                PostTransLineToGenJnlLine(TransferHeader, TransferShipmentHeader."No.");
            until TempGSTPostingBufferFinal.Next() = 0;

        OnBeforeGetInventoryPostingSetup(TempGSTPostingBufferFinal, TransferHeader, TransferShipmentHeader, IsHandled);
        if IsHandled then
            exit;

        TempTransferBufferFinal.Reset();
        TempTransferBufferFinal.SetCurrentKey("sorting no.");
        TempTransferBufferFinal.SetAscending("Sorting No.", false);
        OnFindTempTransferBufferFinal(TempTransferBufferFinal, TempGSTPostingBufferFinal, TransferHeader, TransferShipmentHeader);
        if TempTransferBufferFinal.Findset() then
            repeat
                ValidateTransferLineForAccountSetup(TransferHeader, TransferShipmentHeader, InventoryPostingSetup);

                OnBeforePostGeneralEntries(TempTransferBufferFinal, TransferShipmentHeader, TransferHeader, InventoryPostingSetup);
                PostGeneralEntries(TempTransferBufferFinal, TransferShipmentHeader, TransferHeader, InventoryPostingSetup);
            until TempTransferBufferFinal.Next() = 0;
    end;

    local procedure ValidateTransferLineForAccountSetup(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header"; var InventoryPostingSetup: Record "Inventory Posting Setup")
    var
        TransferLine: Record "Transfer Line";
        IsHandled: Boolean;
    begin
        OnBeforeValidateTransferLineForAccountSetup(TransferHeader, TransferShipmentHeader, TempTransferBufferFinal, TempGSTPostingBufferFinal, IsHandled);
        if IsHandled then
            exit;

        TransferLine.LoadFields("Document No.", "Item No.", "HSN/SAC Code");
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.SetRange("Item No.", TempTransferBufferFinal."Item No.");
        OnFindTransferLineInTempTransferBufferFinalLoop(TransferLine, TempTransferBufferFinal, TempGSTPostingBufferFinal, TransferHeader, TransferShipmentHeader);

        TransferLine.SetFilter("HSN/SAC Code", '<>%1', '');
        if not TransferLine.IsEmpty() then begin
            OnBeforeGetInvPostingSetupOnAfterFindTempTransferBuffer(TempTransferBufferFinal, TempGSTPostingBufferFinal, TransferHeader, TransferShipmentHeader, TransferLine, InventoryPostingSetup);
            InventoryPostingSetup.Get(TransferHeader."In-Transit Code", TempTransferBufferFinal."Inventory Posting Group");
            InventoryPostingSetup.TestField("Unrealized Profit Account");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeTransferOrderPostShipment', '', False, False)]
    local procedure FillGSTLedgerBuffer(var TransferHeader: Record "Transfer Header")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
    begin
        ClearBuffers();
        DetailedGSTEntryBuffer.SetRange("Document Type", DetailedGSTEntryBuffer."Document Type"::Quote);
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::Transfer);
        DetailedGSTEntryBuffer.SetRange("Document No.", TransferHeader."No.");
        if DetailedGSTEntryBuffer.FindFirst() then
            DetailedGSTEntryBuffer.DeleteAll(true);

        FillDetailLedgBufferTransfer(TransferHeader."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Header", 'OnAfterCopyFromTransferHeader', '', False, False)]
    local procedure CopyInfointoTransShptHeader(TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
        TransferShipmentHeader."Time of Removal" := TransferHeader."Time of Removal";
        TransferShipmentHeader."Vehicle No." := TransferHeader."Vehicle No.";
        TransferShipmentHeader."LR/RR No." := TransferHeader."LR/RR No.";
        TransferShipmentHeader."LR/RR Date" := TransferHeader."LR/RR Date";
        TransferShipmentHeader."Mode of Transport" := TransferHeader."Mode of Transport";
        TransferShipmentHeader."Distance (Km)" := TransferHeader."Distance (Km)";
        TransferShipmentHeader."Vehicle Type" := TransferHeader."Vehicle Type";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeInsertTransShptLine', '', False, False)]
    local procedure FillBuffer(var TransShptLine: Record "Transfer Shipment Line"; TransLine: Record "Transfer Line")
    var
        GSTGroup: Record "GST Group";
        IsHandled: Boolean;
    begin
        OnBeforeInsertTransShptLineFillBuffer(TransShptLine, TransLine, IsHandled);
        if IsHandled then
            exit;

        if GSTGroup.Get(TransLine."GST Group Code") and (GSTGroup."GST Group Type" <> GSTGroup."GST Group Type"::Goods) then
            Error(GSTGroupServiceErr);

        if (TransLine."Qty. to Ship" <> 0) and (GetGSTAmount(TransLine.RecordId) <> 0) then
            FillGSTPostingBuffer(TransLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnPostItemOnBeforeUpdateUnitCost', '', false, false)]
    local procedure GetTranfsrePrice(GlobalItemLedgEntry: Record "Item Ledger Entry")
    begin
        if GlobalItemLedgEntry."Entry Type" = GlobalItemLedgEntry."Entry Type"::Transfer then begin
            GlobalItemLedgEntry.CalcFields("Cost Amount (Actual)");
            TransferCost := GlobalItemLedgEntry."Cost Amount (Actual)";
            TransferQuantity := Abs(GlobalItemLedgEntry.Quantity);
        end;
    end;

    local procedure PostGeneralEntries(
        var TempTransferBufferFinal: Record "Transfer Buffer";
        var TransferShipmentHeader: Record "Transfer Shipment Header";
        var TransferHeader: Record "Transfer Header";
        var InventoryPostingSetup: Record "Inventory Posting Setup")
    var
        IsHandled: Boolean;
    begin
        OnBeforePostGeneralJnlLineForUnrealizedGainOrLoss(GenJournalLine, TempTransferBufferFinal, TransferShipmentHeader, TransferHeader, InventoryPostingSetup, GenJnlPostLine, IsHandled);
        if IsHandled then
            exit;

        GenJournalLine.Init();
        GenJournalLine."Posting Date" := TransferHeader."Posting Date";
        GenJournalLine."Document Date" := TransferHeader."Posting Date";
        GenJournalLine."Document No." := TransferShipmentHeader."No.";
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
        GenJournalLine."Account No." := InventoryPostingSetup."Unrealized Profit Account";
        GenJournalLine."System-Created Entry" := TempTransferBufferFinal."System-Created Entry";
        GenJournalLine.Amount := TempTransferBufferFinal.Amount + TempTransferBufferFinal."Charges Amount";
        GenJournalLine.Quantity := TempTransferBufferFinal.Quantity;
        GenJournalLine."Shortcut Dimension 1 Code" := TempTransferBufferFinal."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TempTransferBufferFinal."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TempTransferBufferFinal."Dimension Set ID";
        GenJournalLine.Description := StrSubstNo(TransferShipmentNoLbl, TransferShipmentHeader."No.");
        OnBeforeRunGenJnlPostLineForCharges(GenJournalLine, TempTransferBufferFinal, TransferShipmentHeader, TransferHeader, InventoryPostingSetup);
        if GenJournalLine.Amount <> 0 then
            RunGenJnlPostLine(GenJournalLine);

        GenJournalLine.Init();
        GenJournalLine."Posting Date" := TransferHeader."Posting Date";
        GenJournalLine."Document Date" := TransferHeader."Posting Date";
        GenJournalLine."Document No." := TransferShipmentHeader."No.";
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
        GenJournalLine."Account No." := InventoryPostingSetup."Unrealized Profit Account";
        GenJournalLine."System-Created Entry" := TempTransferBufferFinal."System-Created Entry";
        GenJournalLine.Amount := -TempTransferBufferFinal."Excise Amount";
        GenJournalLine."Shortcut Dimension 1 Code" := TempTransferBufferFinal."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TempTransferBufferFinal."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TempTransferBufferFinal."Dimension Set ID";
        GenJournalLine.Description := STRSUBSTNO(TransferShipmentNoLbl, TransferShipmentHeader."No.");
        OnBeforePostGeneralJnlLineForExcise(GenJournalLine, TempTransferBufferFinal, TransferShipmentHeader, TransferHeader, InventoryPostingSetup);
        if GenJournalLine."Amount" <> 0 then
            RunGenJnlPostLine(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Transfer Shipment", 'OnAfterInsertNewShipmentLine', '', false, false)]
    local procedure FillDetailedGSTLedgerEntriesUndoTransferShipment(var TransShptLine: Record "Transfer Shipment Line"; DocLineNo: Integer)
    var
        OldDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        TransferShipmentLineNew: Record "Transfer Shipment Line";
        IsHandled: Boolean;
    begin
        OnBeforeFillDetailedGSTLedgerEntriesUndoTransferShipment(TransShptLine, DocLineNo, IsHandled);
        if IsHandled then
            exit;

        TransferShipmentLineNew.Get(TransShptLine."Document No.", DocLineNo);

        OldDetailedGSTLedgerEntry.SetRange("Document No.", TransShptLine."Document No.");
        OldDetailedGSTLedgerEntry.SetRange("Document Line No.", TransShptLine."Line No.");
        OnFindOldDetailedGSTLedgerEntry(OldDetailedGSTLedgerEntry, TransShptLine);
        if OldDetailedGSTLedgerEntry.FindSet() then
            repeat
                NewDetailedGSTLedgerEntry.Init();
                NewDetailedGSTLedgerEntry.Copy(OldDetailedGSTLedgerEntry);
                NewDetailedGSTLedgerEntry."Entry No." := 0;
                NewDetailedGSTLedgerEntry."Document Line No." := TransferShipmentLineNew."Line No.";
                NewDetailedGSTLedgerEntry."GST Base Amount" := -1 * OldDetailedGSTLedgerEntry."GST Base Amount";
                NewDetailedGSTLedgerEntry."GST Amount" := -1 * OldDetailedGSTLedgerEntry."GST Amount";
                NewDetailedGSTLedgerEntry.Quantity := -1 * OldDetailedGSTLedgerEntry.Quantity;
                NewDetailedGSTLedgerEntry."Amount Loaded on Item" := -1 * OldDetailedGSTLedgerEntry."Amount Loaded on Item";
                NewDetailedGSTLedgerEntry."Remaining Base Amount" := -1 * OldDetailedGSTLedgerEntry."Remaining Base Amount";
                NewDetailedGSTLedgerEntry."Remaining GST Amount" := -1 * OldDetailedGSTLedgerEntry."Remaining GST Amount";
                NewDetailedGSTLedgerEntry."GST Assessable Value" := -1 * OldDetailedGSTLedgerEntry."GST Assessable Value";
                NewDetailedGSTLedgerEntry."Custom Duty Amount" := -1 * OldDetailedGSTLedgerEntry."Custom Duty Amount";
                OnBeforeInsertNewDetailedGSTLedgerEntry(NewDetailedGSTLedgerEntry, OldDetailedGSTLedgerEntry, TransferShipmentLineNew, TransShptLine);
                NewDetailedGSTLedgerEntry.Insert(true);
                PostUndoTransShipmentLineToGenJnlLine(NewDetailedGSTLedgerEntry, TransferShipmentLineNew);
                PostGeneralEntriesUndoShipment(NewDetailedGSTLedgerEntry, TransferShipmentLineNew);
                InsertGSTLedgerEntryTransferUndoShipment(NewDetailedGSTLedgerEntry, TransferShipmentLineNew);
                InsertDetailedGSTEntryInfoUndoTransferShipment(OldDetailedGSTLedgerEntry, NewDetailedGSTLedgerEntry, TransShptLine, TransferShipmentLineNew);
            until OldDetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure InsertGSTLedgerEntryTransferUndoShipment(NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineNew: Record "Transfer Shipment Line")
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        SourceCodeSetup: Record "Source Code Setup";
        IsHandled: Boolean;
    begin
        OnBeforeInsertGSTLedgerEntryTransferUndoShipment(NewDetailedGSTLedgerEntry, TransferShipmentLineNew, IsHandled);
        if IsHandled then
            exit;

        SourceCodeSetup.Get();

        GSTLedgerEntry.Init();
        GSTLedgerEntry."Entry No." := 0;
        GSTLedgerEntry."Gen. Prod. Posting Group" := TransferShipmentLineNew."Gen. Prod. Posting Group";
        GSTLedgerEntry."Posting Date" := NewDetailedGSTLedgerEntry."Posting Date";
        GSTLedgerEntry."Document No." := NewDetailedGSTLedgerEntry."Document No.";
        GSTLedgerEntry."Document Type" := GSTLedgerEntry."Document Type"::Invoice;
        GSTLedgerEntry."GST Base Amount" := NewDetailedGSTLedgerEntry."GST Base Amount";
        GSTLedgerEntry."GST Amount" := NewDetailedGSTLedgerEntry."GST Amount";
        GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::Transfer;
        GSTLedgerEntry."Transaction Type" := GSTLedgerEntry."Transaction Type"::Sales;
        GSTLedgerEntry."External Document No." := NewDetailedGSTLedgerEntry."External Document No.";
        GSTLedgerEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(GSTLedgerEntry."User ID"));
        GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::Transfer;
        GSTLedgerEntry."Source Code" := SourceCodeSetup.Transfer;
        GSTLedgerEntry."Transaction No." := NewDetailedGSTLedgerEntry."Transaction No.";
        GSTLedgerEntry."GST Component Code" := NewDetailedGSTLedgerEntry."GST Component Code";
        OnBeforeInsertNewGSTLedgerEntryTransferUndoShipment(GSTLedgerEntry, NewDetailedGSTLedgerEntry, TransferShipmentLineNew);
        GSTLedgerEntry.Insert();
    end;

    local procedure InsertDetailedGSTEntryInfoUndoTransferShipment(OldDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineOld: Record "Transfer Shipment Line"; TransferShipmentLineNew: Record "Transfer Shipment Line");
    var
        OldDetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        NewDetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTApplicationLibrary: Codeunit "GST Application Library";
        IsHandled: Boolean;
    begin
        OnBeforeInsertDetailedGSTEntryInfoUndoTransferShipment(OldDetailedGSTLedgerEntry, NewDetailedGSTLedgerEntry, TransferShipmentLineOld, TransferShipmentLineNew, IsHandled);
        if IsHandled then
            exit;

        GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(OldDetailedGSTLedgerEntry, OldDetailedGSTLedgerEntryInfo);

        NewDetailedGSTLedgerEntryInfo.Init();
        NewDetailedGSTLedgerEntryInfo.Copy(OldDetailedGSTLedgerEntryInfo);
        NewDetailedGSTLedgerEntryInfo."Entry No." := NewDetailedGSTLedgerEntry."Entry No.";
        OnBeforeInsertNewDetailedGSTEntryInfoUndoTransferShipment(NewDetailedGSTLedgerEntryInfo, OldDetailedGSTLedgerEntryInfo, NewDetailedGSTLedgerEntry, OldDetailedGSTLedgerEntry, TransferShipmentLineNew, TransferShipmentLineOld);
        NewDetailedGSTLedgerEntryInfo.Insert(true);
    end;

    local procedure PostUndoTransShipmentLineToGenJnlLine(NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineNew: Record "Transfer Shipment Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        IsHandled: Boolean;
    begin
        OnBeforePostUndoTransShipmentLineToGenJnlLine(GenJournalLine, NewDetailedGSTLedgerEntry, TransferShipmentLineNew, IsHandled);
        if IsHandled then
            exit;

        SourceCodeSetup.Get();
        GenJournalLine.Init();
        GenJournalLine."Posting Date" := NewDetailedGSTLedgerEntry."Posting Date";
        GenJournalLine.Description := StrSubstNo(TransferShipmentNoLbl, TransferShipmentLineNew."Document No.");
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
        GenJournalLine."Document No." := TransferShipmentLineNew."Document No.";
        GenJournalLine."External Document No." := NewDetailedGSTLedgerEntry."External Document No.";
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        if NewDetailedGSTLedgerEntry."GST Amount" <> 0 then begin
            GenJournalLine.Validate(Amount, Round(NewDetailedGSTLedgerEntry."GST Amount"));
            GenJournalLine."Account No." := NewDetailedGSTLedgerEntry."G/L Account No.";
        end;

        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."GST Group Code" := NewDetailedGSTLedgerEntry."GST Group Code";
        GenJournalLine."GST Component Code" := NewDetailedGSTLedgerEntry."GST Component Code";
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Gen. Prod. Posting Group" := TransferShipmentLineNew."Gen. Prod. Posting Group";
        GenJournalLine."Shortcut Dimension 1 Code" := TransferShipmentLineNew."Shortcut Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TransferShipmentLineNew."Shortcut Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TransferShipmentLineNew."Dimension Set ID";
        GenJournalLine."Location Code" := TransferShipmentLineNew."Transfer-from Code";
        GenJournalLine."Source Code" := SourceCodeSetup.Transfer;

        OnBeforeRunGenJnlPostUndoTransShipmentLine(GenJournalLine, NewDetailedGSTLedgerEntry, TransferShipmentLineNew);
        Clear(GenJnlPostLine);
        RunGenJnlPostLine(GenJournalLine);
    end;

    local procedure PostGeneralEntriesUndoShipment(NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineNew: Record "Transfer Shipment Line")
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        TransferLine: Record "Transfer Line";
        TransCost: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforePostGeneralEntriesUndoShipment(GenJournalLine, NewDetailedGSTLedgerEntry, TransferShipmentLineNew, IsHandled);
        if IsHandled then
            exit;

        TransferLine.Get(TransferShipmentLineNew."Transfer Order No.", TransferShipmentLineNew."Trans. Order Line No.");
        GetTransferCost(TransferShipmentLineNew, TransCost);
        InventoryPostingSetup.Get(TransferShipmentLineNew."In-Transit Code", TransferShipmentLineNew."Inventory Posting Group");
        GenJournalLine.Init();
        GenJournalLine."Posting Date" := NewDetailedGSTLedgerEntry."Posting Date";
        GenJournalLine."Document Date" := NewDetailedGSTLedgerEntry."Posting Date";
        GenJournalLine."Document No." := TransferShipmentLineNew."Document No.";
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
        GenJournalLine."Account No." := InventoryPostingSetup."Unrealized Profit Account";
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine.Amount := -1 * ((TransferLine.Amount - -TransCost) + NewDetailedGSTLedgerEntry."GST Amount");
        GenJournalLine.Quantity := TransferShipmentLineNew.Quantity;
        GenJournalLine."Shortcut Dimension 1 Code" := TransferShipmentLineNew."Shortcut Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TransferShipmentLineNew."Shortcut Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TransferShipmentLineNew."Dimension Set ID";
        GenJournalLine.Description := StrSubstNo(TransferShipmentNoLbl, TransferShipmentLineNew."Document No.");
        if GenJournalLine.Amount <> 0 then
            RunGenJnlPostLine(GenJournalLine);

        GenJournalLine.Init();
        GenJournalLine."Posting Date" := NewDetailedGSTLedgerEntry."Posting Date";
        GenJournalLine."Document Date" := NewDetailedGSTLedgerEntry."Posting Date";
        GenJournalLine."Document No." := TransferShipmentLineNew."Document No.";
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
        GenJournalLine."Account No." := InventoryPostingSetup."Unrealized Profit Account";
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine.Amount := (TransferLine.Amount - -TransCost);
        GenJournalLine."Shortcut Dimension 1 Code" := TransferShipmentLineNew."Shortcut Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TransferShipmentLineNew."Shortcut Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TransferShipmentLineNew."Dimension Set ID";
        GenJournalLine.Description := STRSUBSTNO(TransferShipmentNoLbl, TransferShipmentLineNew."Document No.");
        if GenJournalLine."Amount" <> 0 then
            RunGenJnlPostLine(GenJournalLine);
    end;

    local procedure GetTransferCost(TransferShipmentLine: Record "Transfer Shipment Line"; var TransCost: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetLoadFields("Document No.", "Document No.", "Location Code");
        ItemLedgerEntry.SetRange("Document No.", TransferShipmentLine."Document No.");
        ItemLedgerEntry.SetRange("Document Line No.", TransferShipmentLine."Line No.");
        ItemLedgerEntry.SetRange("Location Code", TransferShipmentLine."Transfer-from Code");
        ItemLedgerEntry.SetAutoCalcFields("Cost Amount (Actual)");
        if ItemLedgerEntry.FindFirst() then
            TransCost := -1 * ItemLedgerEntry."Cost Amount (Actual)";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateGSTTrackingEntryFromTransferOrder(DocumentNo: Code[20]; ItemNo: Code[20]; DocumentLineNo: Integer; OrignalDocType: Enum "Original Doc Type"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertGSTLedgerEntryTransfer(var GSTPostingBuffer: Record "GST Posting Buffer"; var TransferHeader: Record "Transfer Header"; NextTransactionNo: Integer; DocumentNo: Code[20]; SourceCode: Code[10]; DocTransferType: enum "Doc Transfer Type"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateOnBeforeInsertGSTLedgerEntryTransfer(GSTPostingBuffer: Record "GST Posting Buffer"; TransferHeader: Record "Transfer Header"; var GSTLedgerEntry: Record "GST Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertDetailedGSTLedgEntryTransfer(var TransferLine: Record "Transfer Line"; var TransferHeader: Record "Transfer Header"; DocumentNo: Code[20]; TransactionNo: Integer; DocTransferType: Enum "Doc Transfer Type"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertDetailedGSTEntryInfoTransfer(DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer"; var TransferHeader: Record "Transfer Header"; DocTransferType: Enum "Doc Transfer Type"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTransShptLineFillBuffer(var TransShptLine: Record "Transfer Shipment Line"; TransLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetInventoryPostingSetup(var TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary; var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetInvPostingSetupOnAfterFindTempTransferBuffer(var TempTransferBufferFinal: Record "Transfer Buffer" temporary; var TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary; var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header"; var TransferLine: Record "Transfer Line"; var InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGeneralEntries(var TempTransferBufferFinal: Record "Transfer Buffer" temporary; var TransferShipmentHeader: Record "Transfer Shipment Header"; var TransferHeader: Record "Transfer Header"; var InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGeneralJnlLineForUnrealizedGainOrLoss(var GenJournalLine: Record "Gen. Journal Line"; TempTransferBufferFinal: Record "Transfer Buffer"; TransferShipmentHeader: Record "Transfer Shipment Header"; TransferHeader: Record "Transfer Header"; InventoryPostingSetup: Record "Inventory Posting Setup"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunGenJnlPostLineForCharges(var GenJournalLine: Record "Gen. Journal Line"; TempTransferBufferFinal: Record "Transfer Buffer" temporary; TransferShipmentHeader: Record "Transfer Shipment Header"; TransferHeader: Record "Transfer Header"; InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGeneralJnlLineForExcise(var GenJournalLine: Record "Gen. Journal Line"; TempTransferBufferFinal: Record "Transfer Buffer" temporary; TransferShipmentHeader: Record "Transfer Shipment Header"; TransferHeader: Record "Transfer Header"; InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGLEntries(var TempTransferBufferFinal: Record "Transfer Buffer" temporary; var TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary; var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header"; var TransferLine: Record "Transfer Line"; var InventoryPostingSetup: Record "Inventory Posting Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostTransLineToGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; var TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary; var TempTransferBufferStage: Record "Transfer Buffer" temporary; TransferHeader: Record "Transfer Header"; TransferShptNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunGenJnlPostTransferLine(var GenJournalLine: Record "Gen. Journal Line"; TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary; TempTransferBufferStage: Record "Transfer Buffer" temporary; TransferHeader: Record "Transfer Header"; TransferShptNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunGenJnlPostLineOnBeforeInsertGSTLedgerEntryTransfer(var GenJournalLine: Record "Gen. Journal Line"; TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary; TransferHeader: Record "Transfer Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindTempGSTPostingBufferFinalForTransfer(var TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary; TempTransferBufferFinal: Record "Transfer Buffer" temporary; TransferHeader: Record "Transfer Header"; TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindTempTransferBufferFinal(var TempTransferBufferFinal: Record "Transfer Buffer" temporary; TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary; TransferHeader: Record "Transfer Header"; TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindTransferLineInTempTransferBufferFinalLoop(var TransferLine: Record "Transfer Line"; TempTransferBufferFinal: Record "Transfer Buffer" temporary; TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary; TransferHeader: Record "Transfer Header"; TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateTransferLineForAccountSetup(TransferHeader: Record "Transfer Header"; TransferShipmentHeader: Record "Transfer Shipment Header"; TempTransferBufferFinal: Record "Transfer Buffer" temporary; TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertDetailedGSTEntryInfoUndoTransferShipment(OldDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineOld: Record "Transfer Shipment Line"; TransferShipmentLineNew: Record "Transfer Shipment Line"; IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertNewDetailedGSTEntryInfoUndoTransferShipment(var NewDetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info"; OldDetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info"; NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; OldDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineNew: Record "Transfer Shipment Line"; TransferShipmentLineOld: Record "Transfer Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFillDetailedGSTLedgerEntriesUndoTransferShipment(var TransferShipmentLineOld: Record "Transfer Shipment Line"; NewDocLineNo: Integer; IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindOldDetailedGSTLedgerEntry(var OldDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineOld: Record "Transfer Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertNewDetailedGSTLedgerEntry(var NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; OldDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineNew: Record "Transfer Shipment Line"; TransferShipmentLineOld: Record "Transfer Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertGSTLedgerEntryTransferUndoShipment(NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineNew: Record "Transfer Shipment Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertNewGSTLedgerEntryTransferUndoShipment(var GSTLedgerEntry: Record "GST Ledger Entry"; NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineNew: Record "Transfer Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostUndoTransShipmentLineToGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineNew: Record "Transfer Shipment Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunGenJnlPostUndoTransShipmentLine(var GenJournalLine: Record "Gen. Journal Line"; NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineNew: Record "Transfer Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGeneralEntriesUndoShipment(var GenJournalLine: Record "Gen. Journal Line"; NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; TransferShipmentLineNew: Record "Transfer Shipment Line"; var IsHandled: Boolean)
    begin
    end;
}
