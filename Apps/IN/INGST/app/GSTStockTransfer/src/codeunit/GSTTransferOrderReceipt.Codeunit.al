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
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Transfer;
using Microsoft.Purchases.Vendor;

codeunit 18390 "GST Transfer Order Receipt"
{
    SingleInstance = True;

    var
        TempGSTPostingBufferStage: Record "GST Posting Buffer" temporary;
        TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary;
        TempTransferBufferStage: Record "Transfer Buffer" temporary;
        TempTransferBufferFinal: Record "Transfer Buffer" temporary;
        GenJnlLine: Record "Gen. Journal Line";
        TempItemJnlLine: Record "Item Journal Line" temporary;
        GSTTransferOrderShipment: Codeunit "GST Transfer order Shipment";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GSTBaseValidation: Codeunit "GST Base Validation";
        CustomDutyAmount: Decimal;
        ItemJournalCustom: Decimal;
        RoundDiffAmt: Decimal;
        TransReceiptHeaderNo: Code[20];
        ItemLedgerEntryNo: Integer;
        LineNo: Integer;
        TotalQuantity: Decimal;
        FirstExecution: Boolean;
        GSTAmountLoaded: Decimal;
        TransferCost: Decimal;
        TransferQuantity: Decimal;
        GSTAssessableErr: Label 'GST Assessable Value must be 0 if GST Group Type is Service while transferring from Bonded Warehouse location.';
        GSTCustomDutyErr: Label 'Custom Duty Amount must be 0 if GST Group Type is Service while transferring from Bonded Warehouse location.';
        GSTGroupServiceErr: Label 'You cannot select GST Group Type Service for transfer.';
        TransferReceiptNoLbl: Label 'Transfer - %1', Comment = '%1 = Transfer Receipt No.';

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure CopyInfotoReceiptLine(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line")
    var
        Location: Record Location;
    begin
        if not Location.Get(TransferLine."Transfer-from Code") then
            exit;

        if not Location."Bonded warehouse" then begin
            TransferReceiptLine."GST Group Code" := TransferLine."GST Group Code";
            TransferReceiptLine."GST Credit" := TransferLine."GST Credit";
            TransferReceiptLine."HSN/SAC Code" := TransferLine."HSN/SAC Code";
            TransferReceiptLine.Exempted := TransferLine.Exempted;
        end;

        TransferReceiptLine."Unit Price" := TransferLine."Transfer Price";
        TransferReceiptLine.Amount := TransferLine.Amount * TransferLine."Qty. to Receive" / TransferLine.Quantity;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeTransRcptHeaderInsert', '', false, false)]
    local procedure GetPostingNoSeries(TransferHeader: Record "Transfer Header"; var TransferReceiptHeader: Record "Transfer Receipt Header")
    var
        NoSeriesCodeunit: Codeunit "No. Series";
        NoSeries: Code[20];
    begin
        NoSeries := GetTransferReceiptPostingNoSeries(TransferHeader);
        if NoSeries <> '' then begin
            TransferReceiptHeader."No. Series" := NoSeries;
            if TransferReceiptHeader."No. Series" <> '' then
                TransferReceiptHeader."No." := NoSeriesCodeunit.GetNextNo(TransferReceiptHeader."No. Series", TransferHeader."Posting Date");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeTransferOrderPostReceipt', '', false, false)]
    local procedure ClearBuffer()
    begin
        ClearAll();
        TempTransferBufferStage.DeleteAll();
        TempTransferBufferFinal.DeleteAll();
        TempGSTPostingBufferStage.DeleteAll();
        TempGSTPostingBufferFinal.DeleteAll();
        TempItemJnlLine.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterItemValuePosting', '', false, false)]
    local procedure GetTranfsrePrice(var ValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line")
    begin
        if (ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Transfer) and
            (ItemJournalLine."Value Entry Type" <> ItemJournalLine."Value Entry Type"::Revaluation) then begin
            TransferCost := ValueEntry."Cost Amount (Actual)";
            TransferQuantity := Abs(ValueEntry."Invoiced Quantity");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeTransRcptHeaderInsert', '', false, false)]
    local procedure SetTransferReceiptNo(var TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
        TransReceiptHeaderNo := TransferReceiptHeader."No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterInsertTransRcptLine', '', false, false)]
    local procedure CeateGSTLedgerEntry(TransLine: Record "Transfer Line"; var TransRcptLine: Record "Transfer Receipt Line")
    var
        TransferHeader: Record "Transfer Header";
        DocTransferType: Enum "Doc Transfer Type";
    begin
        ItemJournalCustom := 0;
        ItemLedgerEntryNo := 0;
        TransferHeader.Get(TransLine."Document No.");
        GSTTransferOrderShipment.InsertDetailedGSTLedgEntryTransfer(TransLine,
            TransferHeader,
            TransRcptLine."Document No.",
            GenJnlPostLine.GetNextTransactionNo(),
            DocTransferType::"Transfer Receipt");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterPostItemJnlLine', '', false, false)]
    local procedure InsertTransferBuffer(var TransLine3: Record "Transfer Line"; var TransRcptHeader2: Record "Transfer Receipt Header"; var TransRcptLine2: Record "Transfer Receipt Line"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    begin
        FillTransferBuffer(TransLine3);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterTransRcptLineModify', '', false, false)]
    local procedure FillReceiptLine(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line")
    begin
        TransferReceiptLine."GST Group Code" := TransferLine."GST Group Code";
        TransferReceiptLine."GST Credit" := TransferLine."GST Credit";
        TransferReceiptLine."HSN/SAC Code" := TransferLine."HSN/SAC Code";
        TransferReceiptLine.Exempted := TransferLine.Exempted;
        TransferReceiptLine."Custom Duty Amount" := TransferLine."Custom Duty Amount";
        TransferReceiptLine."GST Assessable Value" := TransferLine."GST Assessable Value";
        TransferReceiptLine.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnCheckTransLine', '', false, false)]
    local procedure FillBuffers(TransferLine: Record "Transfer Line")
    var
        GSTGroup: Record "GST Group";
        DocTransactionType: Enum "Transaction Type Enum";
        DocumentType: Enum "Document Type Enum";
        IsHandled: Boolean;
    begin
        OnBeforeInsertTransRcptLineFillBuffer(TransferLine, IsHandled);
        if IsHandled then
            exit;

        if TransferLine.Quantity <> 0 then
            GSTAmountLoaded := Abs(
                RoundTotalGSTAmountLoadedQtyFactor(
                DocTransactionType::Transfer,
                DocumentType::Quote,
                TransferLine."Document No.",
                TransferLine."Line No.",
                TransferLine."Qty. to Receive" / TransferLine.Quantity,
            '')
        );

        if GSTGroup.Get(TransferLine."GST Group Code") and (GSTGroup."GST Group Type" <> GSTGroup."GST Group Type"::Goods) then
            Error(GSTGroupServiceErr);

        if (TransferLine."Qty. to Receive" <> 0) and (GetGSTAmount(TransferLine.RecordId) <> 0) then
            FillGSTPostingBuffer(TransferLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeTransferOrderPostReceipt', '', false, false)]
    local procedure CheckGSTValidation(var TransferHeader: Record "Transfer Header")
    begin
        ClearBuffer();
        CheckValidations(TransferHeader);
        GSTBaseValidation.CheckGSTAccountingPeriod(TransferHeader."Posting Date", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeTransRcptHeaderInsert', '', false, false)]
    local procedure CopyInfointoTransRcpttHeader(var TransferReceiptHeader: Record "Transfer Receipt Header"; TransferHeader: Record "Transfer Header")
    begin
        TransferReceiptHeader."Vendor Invoice No." := TransferHeader."Vendor Invoice No.";
        TransferReceiptHeader."Bill of Entry No." := TransferHeader."Bill of Entry No.";
        TransferReceiptHeader."Bill of Entry Date" := TransferHeader."Bill of Entry Date";
        TransferReceiptHeader."Vendor No." := TransferHeader."Vendor No.";
        TransferReceiptHeader."Distance (Km)" := TransferHeader."Distance (Km)";
        TransferReceiptHeader."Vehicle Type" := TransferHeader."Vehicle Type";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeTransRcptHeaderInsert', '', false, false)]
    local procedure FillGSTLedgerBuffer(TransferHeader: Record "Transfer Header")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
    begin
        ClearBuffer();
        DetailedGSTEntryBuffer.SetRange("Document Type", DetailedGSTEntryBuffer."Document Type"::Quote);
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::Transfer);
        DetailedGSTEntryBuffer.SetRange("Document No.", TransferHeader."No.");
        if DetailedGSTEntryBuffer.FindFirst() then
            DetailedGSTEntryBuffer.DeleteAll(true);

        FillDetailLedgBufferTransfer(TransferHeader."No.");
        GetCustomDutyAmount(TransferHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeDeleteOneTransferHeader', '', false, false)]
    local procedure PostEntries(TransferHeader: Record "Transfer Header"; TransferReceiptHeader: Record "Transfer Receipt Header")
    var
        Item: Record Item;
        CustomDutyBase: Boolean;
        IsHandled: Boolean;
    begin
        FirstExecution := true;
        if TransReceiptHeaderNo <> TransferReceiptHeader."No." then
            TransReceiptHeaderNo := TransferReceiptHeader."No.";

        OnBeforePostTransferOrderReceiptGLEntries(TempTransferBufferfinal, TransferHeader, TransferReceiptHeader, IsHandled);
        if IsHandled then
            exit;

        //Post GL Entries
        TempTransferBufferfinal.Reset();
        if TempTransferBufferfinal.FindLast() then
            repeat
                PostGLEntries(TransferHeader, TempTransferBufferfinal, TransferReceiptHeader);
                // Post GST to G/L entries from GST posting buffer.. GST Sales
                GSTPostingBufferforTransferDocument(CustomDutyBase, TransferHeader);
                // Post Unrealized Profit Account Entries
                OnBeforePostUnrealizedPorfitAccountEntries(TempTransferBufferfinal, TransferHeader, TransferReceiptHeader);
                if not (TempTransferBufferfinal."Gen. Bus. Posting Group" <> '') then
                    PostUnrealizedProfitAccountEntries(TransferHeader, TempTransferBufferfinal, TransferReceiptHeader);

                // Amount loaded on inventory
                OnBeforePostInventoryEntries(TempTransferBufferfinal, TransferHeader);
                if (TempTransferBufferfinal."Amount Loaded on Inventory" <> 0) or (TempTransferBufferfinal."GST Amount Loaded on Inventory" <> 0) then
                    PostInventoryEntries(TransferHeader, TempTransferBufferfinal);

                // Purchase Account posting
                if (TempTransferBufferfinal."Gen. Bus. Posting Group" <> '') then begin
                    Item.Get(TempTransferBufferfinal."Item No.");
                    if not Item.Exempted then
                        TempTransferBufferfinal.TestField("GST Amount");

                    GSTPurchAccPosting(TransferHeader, TempTransferBufferfinal);
                end;
            until TempTransferBufferfinal.Next(-1) = 0;
        TempTransferBufferfinal.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterTransLineUpdateQtyReceived', '', false, false)]
    local procedure CreateGSTTrackingEntry(var TransferLine: Record "Transfer Line")
    var
        TransferHeader: Record "Transfer Header";
        OriginalDocType: Enum "Original Doc Type";
    begin
        ItemJournalCustom := 0;
        ItemLedgerEntryNo := 0;
        TransferHeader.Get(TransferLine."Document No.");
        GSTTransferOrderShipment.UpdateGSTTrackingEntryFromTransferOrder(TransReceiptHeaderNo,
            TransferLine."Item No.",
            TransferLine."Line No.",
            OriginalDocType::"Transfer Receipt");
    end;

    local procedure PostGLEntries(var TransferHeader: Record "Transfer Header"; TempTransferBufferfinal: Record "Transfer Buffer"; TransferReceiptHeader: Record "Transfer Receipt Header")
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Item: Record Item;
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        InventoryPostingSetup.Get(TransferHeader."In-Transit Code", TempTransferBufferfinal."Inventory Posting Group");
        if Item.Get(TempTransferBufferfinal."Item No.") and (item."HSN/SAC Code" <> '') then
            InventoryPostingSetup.TestField("Unrealized Profit Account");

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := TransferHeader."Posting Date";
        GenJnlLine."Document Date" := TransferHeader."Posting Date";
        GenJnlLine."Document No." := TransferReceiptHeader."No.";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        if (TempTransferBufferfinal."Gen. Bus. Posting Group" <> '') then
            GenJnlLine."Account No." := GetIGSTImportAccountNo(TempTransferBufferfinal."Location Code")
        else
            GenJnlLine."Account No." := InventoryPostingSetup."Unrealized Profit Account";

        GenJnlLine."System-Created Entry" := TempTransferBufferfinal."System-Created Entry";
        GenJnlLine."Gen. Bus. Posting Group" := TempTransferBufferfinal."Gen. Bus. Posting Group";
        GenJnlLine."Gen. Prod. Posting Group" := TempTransferBufferfinal."Gen. Prod. Posting Group";
        if (TempTransferBufferfinal."Gen. Bus. Posting Group" <> '') then
            GenJnlLine.Amount := (TempTransferBufferfinal."GST Amount")
        else
            GenJnlLine.Amount := -(TempTransferBufferfinal.Amount + TempTransferBufferfinal."Charges Amount" + TempTransferBufferfinal."GST Amount");

        GenJnlLine.Quantity := TempTransferBufferfinal.Quantity;
        GenJnlLine."Source Code" := SourcecodeSetup.Transfer;
        GenJnlLine."Shortcut Dimension 1 Code" := TempTransferBufferfinal."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := TempTransferBufferfinal."Global Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := TempTransferBufferfinal."Dimension Set ID";
        GenJnlLine.Description := StrSubstNo(TransferReceiptNoLbl, TransferReceiptHeader."No.");
        if (GenJnlLine.Amount <> 0) then
            RunGenJnlPostLine(GenJnlLine);
    end;

    local procedure PostInventoryEntries(var TransferHeader: Record "Transfer Header"; TempTransferBufferfinal: Record "Transfer Buffer")
    var
        GeneralPostingSetup: Record "General Posting Setup";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        GeneralPostingSetup.Get(TempTransferBufferfinal."Gen. Bus. Posting Group", TempTransferBufferfinal."Gen. Prod. Posting Group");
        GeneralPostingSetup.TestField("Inventory Adjmt. Account");

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := TransferHeader."Posting Date";
        GenJnlLine."Document Date" := TransferHeader."Posting Date";
        GenJnlLine."Document No." := TransReceiptHeaderNo;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        if (TempTransferBufferfinal."Gen. Bus. Posting Group" <> '') then
            GenJnlLine."Account No." := TempTransferBufferfinal."G/L Account"
        else
            GenJnlLine."Account No." := GeneralPostingSetup."Inventory Adjmt. Account";

        GenJnlLine."System-Created Entry" := TempTransferBufferfinal."System-Created Entry";
        GenJnlLine.Amount := Abs(TempTransferBufferfinal."Amount Loaded on Inventory" + TempTransferBufferfinal."GST Amount Loaded on Inventory");
        GenJnlLine."Gen. Bus. Posting Group" := TempTransferBufferfinal."Gen. Bus. Posting Group";
        GenJnlLine."Gen. Prod. Posting Group" := TempTransferBufferfinal."Gen. Prod. Posting Group";
        GenJnlLine."Source Code" := SourcecodeSetup.Transfer;
        GenJnlLine."Shortcut Dimension 1 Code" := TempTransferBufferfinal."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := TempTransferBufferfinal."Global Dimension 2 Code";
        GenJnlLine.Description := StrSubstNo(TransferReceiptNoLbl, TransReceiptHeaderNo);
        if (GenJnlLine.Amount <> 0) then
            RunGenJnlPostLine(GenJnlLine);
    end;

    local procedure PostUnrealizedProfitAccountEntries(TransferHeader: Record "Transfer Header"; TempTransferBufferfinal: Record "Transfer Buffer"; TransferReceiptHeader: Record "Transfer Receipt Header")
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        SourceCodeSetup: Record "Source Code Setup";
        Item: Record Item;
    begin
        SourceCodeSetup.Get();
        InventoryPostingSetup.Get(TransferHeader."Transfer-to Code", TempTransferBufferfinal."Inventory Posting Group");
        if Item.Get(TempTransferBufferFinal."Item No.") and (item."HSN/SAC Code" <> '') then
            InventoryPostingSetup.TestField("Unrealized Profit Account");

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := TransferHeader."Posting Date";
        GenJnlLine."Document Date" := TransferHeader."Posting Date";
        GenJnlLine."Document No." := TransferReceiptHeader."No.";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        if (TempTransferBufferfinal."Gen. Bus. Posting Group" <> '') then
            GenJnlLine."Account No." := GetIGSTImportAccountNo(TempTransferBufferfinal."Location Code")
        else
            GenJnlLine."Account No." := InventoryPostingSetup."Unrealized Profit Account";

        if (TempTransferBufferfinal."Gen. Bus. Posting Group" <> '') then
            GenJnlLine.Amount := (TempTransferBufferfinal.Amount)
        else
            GenJnlLine.Amount := TempTransferBufferfinal.Amount;

        GenJnlLine."System-Created Entry" := TempTransferBufferfinal."System-Created Entry";
        GenJnlLine."Source Code" := SourceCodeSetup.Transfer;
        GenJnlLine."Gen. Bus. Posting Group" := TempTransferBufferfinal."Gen. Bus. Posting Group";
        GenJnlLine."Gen. Prod. Posting Group" := TempTransferBufferfinal."Gen. Prod. Posting Group";
        GenJnlLine."Shortcut Dimension 1 Code" := TempTransferBufferfinal."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := TempTransferBufferfinal."Global Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := TempTransferBufferfinal."Dimension Set ID";
        GenJnlLine.Description := StrSubstNo(TransferReceiptNoLbl, TransReceiptHeaderNo);
        if (GenJnlLine.Amount <> 0) then
            RunGenJnlPostLine(GenJnlLine);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertValueEntry', '', false, false)]
    local procedure PostRevaulaedEntry(var ValueEntry: Record "Value Entry")
    begin
        if (ValueEntry."Item Ledger Entry Quantity" > 0) and (ValueEntry."Document Type" = ValueEntry."Document Type"::"Transfer Receipt") then
            ItemLedgerEntryNo := ValueEntry."Item Ledger Entry No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure SetMarking(TransferReceiptLine: Record "Transfer Receipt Line")
    begin
        ItemJournalCustom := TransferReceiptLine."Custom Duty Amount" + GSTAmountLoaded;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterItemValuePosting', '', false, false)]
    local procedure InitRevaluationEntryForGSTAndUnrealizedProfit(var ItemJournalLine: Record "Item Journal Line"; var ValueEntry: Record "Value Entry")
    begin
        InitRevaluationEntryGST(ItemJournalLine);
        InitRevaluationEntryUnrealizedProfit(ItemJournalLine, ValueEntry);
    end;

    local procedure FillDetailLedgBufferTransfer(DocNo: Code[20])
    var
        TransferLine: Record "Transfer Line";
        TransferHeader: Record "Transfer Header";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction value";
        Item: Record Item;

    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        GSTSetup.TestField("Cess Tax Type");
        TransferHeader.Get(DocNo);

        TransferLine.Reset();
        TransferLine.SetRange("Document No.", DocNo);
        if TransferLine.FindSet() then
            repeat
                if TransferLine."Item No." <> '' then begin
                    Item.Get(TransferLine."Item No.");
                    TransferLine.TestField(Quantity);

                    TaxTransactionValue.Reset();
                    TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                    TaxTransactionValue.SetFilter("Tax Type", '%1|%2', GSTSetup."GST Tax Type", GSTSetup."Cess Tax Type");
                    TaxTransactionValue.SetRange("Tax Record ID", TransferLine.RecordId);
                    TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
                    TaxTransactionValue.SetFilter(Amount, '<>%1', 0);
                    if TaxTransactionValue.FindSet() then
                        repeat
                            FillDetailedGSTEntryBuffer(DetailedGSTEntryBuffer, TransferHeader, Item, TransferLine, TaxTransactionValue);
                        until TaxTransactionValue.Next() = 0;
                end;
            until TransferLine.Next() = 0;
    end;

    local procedure FillDetailedGSTEntryBuffer(
        var DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        TransferHeader: Record "Transfer Header";
        Item: Record Item;
        TransferLine: Record "Transfer Line";
        TaxTransactionValue: Record "Tax Transaction value")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GSTGroup: Record "GST Group";
        GSTSetup: Record "GST Setup";
        GSTBaseValidation: Codeunit "GST Base Validation";
        DocumentType: Enum "Document Type Enum";
        TransactionType: Enum "Transaction Type Enum";
        Sign: Integer;
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        GSTSetup.TestField("Cess Tax Type");

        GeneralLedgerSetup.Get();
        Sign := GSTbaseValidation.GetSignTransfer(DocumentType::Quote, TransactionType::"Transfer");

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
    end;

    local procedure CheckValidations(TransferHeader: Record "Transfer Header")
    var
        Location: Record Location;
        TransferLine: Record "Transfer Line";
    begin
        if not location.Get(TransferHeader."Transfer-from Code") then
            exit;

        if not Location."Bonded warehouse" then
            exit;

        TransferLine.Reset();
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.SetFilter(Quantity, '<>0');
        TransferLine.SetRange("Derived From Line No.", 0);
        TransferLine.SetFilter("Qty. to Receive", '<>0');
        if TransferLine.FindSet() then
            repeat
                if not IsGSTGroupForGoods(TransferLine) then
                    Error(GSTGroupServiceErr);

                if (TransferLine."GST Assessable Value" <> 0) and (not IsGSTGroupForGoods(TransferLine)) then
                    Error(GSTAssessableErr);

                if (TransferLine."Custom Duty Amount" <> 0) and (not IsGSTGroupForGoods(TransferLine)) then
                    Error(GSTCustomDutyErr);

                TransferLine.TestField("GST Assessable Value");
            until TransferLine.Next() = 0;

        TransferHeader.TestField("Vendor No.");
        TransferHeader.TestField("Bill of Entry Date");
        TransferHeader.TestField("Bill of Entry No.");
    end;

    local procedure IsGSTGroupForGoods(TransferLine: Record "Transfer Line"): Boolean
    var
        GSTGroup: Record "GST Group";
    begin
        if (GSTGroup.Get(TransferLine."GST Group Code") and (GSTGroup."GST Group Type" = GSTGroup."GST Group Type"::Goods)) then
            exit(true);
    end;

    local procedure RoundTotalGSTAmountLoadedQtyFactor(
        TransactionType: Enum "Transaction Type Enum";
        DocumentType: Enum "Document Type Enum";
        DocumentNo: Code[20];
        LineNo: Integer;
        QtyFactor: Decimal;
        CurrencyCode: Code[10]): Decimal
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
                    TotalGSTAmount += DetailedGSTEntryBuffer."Amount Loaded on Item" * QtyFactor;

                if CurrencyCode = '' then
                    TotalGSTAmount := GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code", TotalGSTAmount);

            until DetailedGSTEntryBuffer.Next() = 0;

        Sign := GSTBaseValidation.GETSignTransfer(DocumentType, TransactionType);
        exit(TotalGSTAmount * Sign);
    end;

    local procedure FillGSTPostingBuffer(TransferLine: Record "Transfer Line")
    var
        Location: Record Location;
        BondedLocation: Record Location;
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        TransferHeader: Record "Transfer Header";
        QFactor: Decimal;
        GSTStateCode: Code[10];
    begin
        TransferHeader.Get(TransferLine."Document No.");
        if not Location.Get(TransferHeader."Transfer-to Code") then
            exit;

        if not BondedLocation.Get(TransferHeader."Transfer-from Code") then
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
                if (DetailedGSTEntryBuffer."GST Assessable Value" <> 0) or (DetailedGSTEntryBuffer."Custom Duty Amount" <> 0) then
                    QFactor := 1
                else
                    QFactor := Abs(TransferLine."Qty. to Receive" / TransferLine.Quantity);

                if BondedLocation."Bonded warehouse" then
                    TempGSTPostingBufferStage."GST Base Amount" := -GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent
                                                                    (DetailedGSTEntryBuffer."GST Component Code",
                                                                    (QFactor * (DetailedGSTEntryBuffer."GST Assessable Value" +
                                                                    DetailedGSTEntryBuffer."Custom Duty Amount")))
                else
                    TempGSTPostingBufferStage."GST Base Amount" := -GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code",
                                                                                                                        (QFactor * DetailedGSTEntryBuffer."GST Base Amount"));
                TempGSTPostingBufferStage."GST Amount" := -GSTBaseValidation.RoundGSTPrecisionThroughTaxComponent(DetailedGSTEntryBuffer."GST Component Code", (QFactor * DetailedGSTEntryBuffer."GST Amount"));
                TempGSTPostingBufferStage."GST %" := DetailedGSTEntryBuffer."GST %";
                TempGSTPostingBufferStage."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                TempGSTPostingBufferStage."Custom Duty Amount" := DetailedGSTEntryBuffer."Custom Duty Amount";
                if (not DetailedGSTEntryBuffer."Non-Availment") and (TempGSTPostingBufferStage."GST Amount" <> 0) then
                    TempGSTPostingBufferStage."Account No." := GetGSTReceivableAccountNo(GSTStateCode, DetailedGSTEntryBuffer."GST Component Code")
                else
                    TempGSTPostingBufferStage."Account No." := '';

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
        TempGSTPostingBufferFinal.SetRange("GST Component Code", TempGSTPostingBufferStage."GST Component Code");
        TempGSTPostingBufferFinal.SetRange(Availment, TempGSTPostingBufferStage.Availment);
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

    local procedure GetIGSTImportAccountNo(LocationCode: Code[10]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
        Location: Record Location;
    begin
        if not Location.Get(LocationCode) then
            exit;

        GSTPostingSetup.Reset();
        GSTPostingSetup.SetRange("State Code", Location."State Code");
        GSTPostingSetup.SetRange("Component ID", GSTComponentID('IGST'));
        GSTPostingSetup.FindFirst();
        exit(GSTPostingSetup."IGST Payable A/c (Import)")
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
        Vendor: Record Vendor;
        GeneralPostingSetup: Record "General Posting Setup";
        LocationBonded: Record Location;
        TransferHeader: Record "Transfer Header";
        DocTransactionType: Enum "Transaction Type Enum";
        DocumentType: Enum "Document Type Enum";
    begin
        if (TransferLine."GST Group Code" = '') or (TransferLine."HSN/SAC Code" = '') then
            exit;

        if TransferLine."Qty. to Receive" = 0 then
            exit;

        Clear(TempTransferBufferStage);
        TransferHeader.Get(TransferLine."Document No.");
        LocationBonded.Get(TransferHeader."Transfer-from Code");

        if (TransferHeader."Vendor No." <> '') and (LocationBonded."Bonded warehouse") then begin
            Vendor.Get(TransferHeader."Vendor No.");
            GeneralPostingSetup.Get(Vendor."Gen. Bus. Posting Group", TransferLine."Gen. Prod. Posting Group");
            GeneralPostingSetup.TestField("Purch. Account");
            TempTransferBufferStage."Gen. Bus. Posting Group" := Vendor."Gen. Bus. Posting Group";
            TempTransferBufferStage."G/L Account" := GeneralPostingSetup."Purch. Account";
        end;

        TempTransferBufferStage."Gen. Prod. Posting Group" := TransferLine."Gen. Prod. Posting Group";
        TempTransferBufferStage."System-Created Entry" := true;
        TempTransferBufferStage."Location Code" := TransferLine."Transfer-to Code";
        TempTransferBufferStage."Item No." := TransferLine."Item No.";
        TempTransferBufferStage.Quantity := TransferLine."Qty. to Receive";
        TempTransferBufferStage."Inventory Posting Group" := TransferLine."Inventory Posting Group";
        TempTransferBufferStage."Global Dimension 1 Code" := TransferLine."Shortcut Dimension 1 Code";
        TempTransferBufferStage."Global Dimension 2 Code" := TransferLine."Shortcut Dimension 2 Code";
        TempTransferBufferStage."Dimension Set ID" := TransferLine."Dimension Set ID";
        TempTransferBufferStage."Charges Amount" := TransferLine."Charges to Transfer";
        TempTransferBufferStage."Amount Loaded on Inventory" := TransferLine."Amount Added to Inventory";
        TempTransferBufferStage.Amount := Round(TransferLine."Qty. to Receive" * (TransferLine."Transfer Price" - (-(TransferCost / TransferQuantity))));
        if LocationBonded."Bonded warehouse" then
            TempTransferBufferStage."GST Amount" := -Round(
                RoundTotalGSTAmountQtyFactor(
                    DocTransactionType::Transfer,
                    DocumentType::Quote,
                    TransferLine."Document No.",
                    TransferLine."Line No.",
                    1,
                    '',
                    false)
            )
        else
            TempTransferBufferStage."GST Amount" := Round(
                RoundTotalGSTAmountQtyFactor(
                    DocTransactionType::Transfer,
                    DocumentType::Quote,
                    TransferLine."Document No.",
                    TransferLine."Line No.",
                    TransferLine."Qty. to Receive" / TransferLine.Quantity,
                    '',
                    false)
                );

        if TransferLine."Custom Duty Amount" <> 0 then
            TempTransferBufferStage."Custom Duty Amount" := TransferLine."Custom Duty Amount";

        if TransferLine.Quantity <> 0 then
            TempTransferBufferStage."GST Amount Loaded on Inventory" := Abs(
                RoundTotalGSTAmountLoadedQtyFactor(
                    DocTransactionType::Transfer,
                    DocumentType::Quote,
                    TransferLine."Document No.",
                    TransferLine."Line No.",
                    TransferLine."Qty. to Receive" / TransferLine.Quantity, '')
            );

        GSTAmountLoaded := TempTransferBufferStage."GST Amount Loaded on Inventory";
        UpdTransferBuffer();
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

    local procedure UpdTransferBuffer()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.UpdateGlobalDimFromDimSetID(TempTransferBufferStage."Dimension Set ID",
          TempTransferBufferStage."Global Dimension 1 Code", TempTransferBufferStage."Global Dimension 2 Code");
        ApplyFilterOnTempTransferBufferFinal(TempTransferBufferFinal, TempTransferBufferStage);
        if TempTransferBufferFinal.FindFirst() then begin
            TempTransferBufferFinal.Amount := TempTransferBufferFinal.Amount + TempTransferBufferStage.Amount;
            TempTransferBufferFinal."Amount Loaded on Inventory" := TempTransferBufferFinal."Amount Loaded on Inventory" + TempTransferBufferStage."Amount Loaded on Inventory";
            TempTransferBufferFinal."Charges Amount" := TempTransferBufferFinal."Charges Amount" + TempTransferBufferStage."Charges Amount";
            TempTransferBufferFinal.Quantity := TempTransferBufferFinal.Quantity + TempTransferBufferStage.Quantity;
            TempTransferBufferFinal."GST Amount" := TempTransferBufferFinal."GST Amount" + TempTransferBufferStage."GST Amount";
            TempTransferBufferFinal."GST Amount Loaded on Inventory" := TempTransferBufferFinal."GST Amount Loaded on Inventory" +
                TempTransferBufferStage."GST Amount Loaded on Inventory";
            TempTransferBufferFinal."Custom Duty Amount" := TempTransferBufferFinal."Custom Duty Amount" + TempTransferBufferStage."Custom Duty Amount";
            if not TempTransferBufferStage."System-Created Entry" then
                TempTransferBufferFinal."System-Created Entry" := false;

            TempTransferBufferFinal.Modify();
        end else begin
            TempTransferBufferFinal := TempTransferBufferStage;
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

    local procedure RunGenJnlPostLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure GSTPostingBufferforTransferDocument(CustomDutyBase: Boolean; TransferHeader: Record "Transfer Header")
    begin
        if FirstExecution then begin
            TempGSTPostingBufferFinal.Reset();
            if TempGSTPostingBufferFinal.FindLast() then
                repeat
                    if (TempGSTPostingBufferFinal."Custom Duty Amount" <> 0) and (not CustomDutyBase) then begin
                        CustomDutyBase := true;
                        TempGSTPostingBufferFinal."Custom Duty Amount" := CustomDutyAmount;
                        FillGenJnlLineForCustomDuty(TransferHeader);
                    end;

                    PostTransLineToGenJnlLine(TransferHeader);
                until TempGSTPostingBufferFinal.Next(-1) = 0;

            FirstExecution := false;
        end;
    end;

    local procedure GetCustomDutyAmount(DocumentNo: Code[20])
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", DocumentNo);
        TransferLine.SetFilter("Qty. to Receive", '<>%1', 0);
        TransferLine.SetFilter("Custom Duty Amount", '<>%1', 0);
        TransferLine.SetRange("Derived From Line No.", 0);
        if TransferLine.FindSet() then
            repeat
                CustomDutyAmount += TransferLine."Custom Duty Amount";
            until TransferLine.Next() = 0;
    end;

    local procedure PostTransLineToGenJnlLine(TransferHeader: Record "Transfer Header")
    var
        SourceCodeSetup: Record "Source Code Setup";
        DocTransferType: Enum "Doc Transfer Type";
    begin
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := TransferHeader."Posting Date";
        GenJnlLine.Description := StrSubstNo(TransferReceiptNoLbl, TransReceiptHeaderNo);
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        GenJnlLine."Document No." := TransReceiptHeaderNo;
        GenJnlLine."External Document No." := TransferHeader."No.";
        if TempGSTPostingBufferfinal."GST Amount" <> 0 then begin
            GenJnlLine.Validate(Amount, Round(TempGSTPostingBufferfinal."GST Amount"));
            GenJnlLine."Account No." := TempGSTPostingBufferfinal."Account No.";
        end;

        GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";
        GenJnlLine."GST Group Code" := TempGSTPostingBufferfinal."GST Group Code";
        GenJnlLine."GST Component Code" := TempGSTPostingBufferfinal."GST Component Code";
        GenJnlLine."System-Created Entry" := TempTransferBufferFinal."System-Created Entry";
        GenJnlLine."Gen. Bus. Posting Group" := TempGSTPostingBufferfinal."Gen. Bus. Posting Group";
        GenJnlLine."Gen. Prod. Posting Group" := TempGSTPostingBufferfinal."Gen. Prod. Posting Group";
        GenJnlLine."Shortcut Dimension 1 Code" := TempGSTPostingBufferfinal."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := TempGSTPostingBufferfinal."Global Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := TempGSTPostingBufferfinal."Dimension Set ID";
        GenJnlLine."Location Code" := TransferHeader."Transfer-to Code";
        SourceCodeSetup.Get();
        GenJnlLine."Source Code" := SourceCodeSetup.Transfer;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        if TempGSTPostingBufferFinal."Account No." <> '' then
            RunGenJnlPostLine(GenJnlLine);

        GSTTransferOrderShipment.InsertGSTLedgerEntryTransfer(
            TempGSTPostingBufferFinal,
            TransferHeader,
            GenJnlPostLine.GetNextTransactionNo(),
            GenJnlLine."Document No.",
            SourceCodeSetup.Transfer,
            DocTransferType::"Transfer Receipt");
    end;

    local procedure GSTPurchAccPosting(TransferHeader: Record "Transfer Header"; TempTransferBufferfinal: Record "Transfer Buffer")
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := TransferHeader."Posting Date";
        GenJnlLine."Document Date" := TransferHeader."Posting Date";
        GenJnlLine."Document No." := TransReceiptHeaderNo;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        GenJnlLine."Account No." := TempTransferBufferFinal."G/L Account";
        GenJnlLine."System-Created Entry" := TempTransferBufferFinal."System-Created Entry";
        GenJnlLine.Amount := TempTransferBufferFinal."Custom Duty Amount";
        GenJnlLine."Source Code" := SourceCodeSetup.Transfer;
        GenJnlLine."Gen. Bus. Posting Group" := TempTransferBufferFinal."Gen. Bus. Posting Group";
        GenJnlLine."Gen. Prod. Posting Group" := TempTransferBufferFinal."Gen. Prod. Posting Group";
        GenJnlLine."Shortcut Dimension 1 Code" := TempTransferBufferFinal."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := TempTransferBufferFinal."Global Dimension 2 Code";
        GenJnlLine.Description := StrSubstNo(TransferReceiptNoLbl, TransReceiptHeaderNo);
        if GenJnlLine.Amount <> 0 then
            RunGenJnlPostLine(GenJnlLine);
    end;

    local procedure FillGenJnlLineForCustomDuty(TransferHeader: Record "Transfer Header")
    var
        SourceCodeSetup: Record "Source Code Setup";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        SourceCodeSetup.Get();

        GenJournalLine.Init();
        GenJournalLine."Posting Date" := TransferHeader."Posting Date";
        GenJournalLine.Description := StrSubstNo(TransferReceiptNoLbl, TransReceiptHeaderNo);
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
        GenJournalLine."Document No." := TransReceiptHeaderNo;
        GenJournalLine."External Document No." := TransferHeader."No.";
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Account No." := GetIGSTImportAccountNo(TempTransferBufferFinal."Location Code");
        GenJournalLine."Bal. Account No." := '';
        GenJournalLine.Validate(Amount, -Round(TempGSTPostingBufferFinal."Custom Duty Amount"));
        GenJournalLine."Gen. Bus. Posting Group" := TempGSTPostingBufferFinal."Gen. Bus. Posting Group";
        GenJournalLine."Gen. Prod. Posting Group" := TempGSTPostingBufferFinal."Gen. Prod. Posting Group";
        GenJournalLine."Shortcut Dimension 1 Code" := TempGSTPostingBufferFinal."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TempGSTPostingBufferFinal."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TempGSTPostingBufferFinal."Dimension Set ID";
        GenJournalLine."GST Component Code" := TempGSTPostingBufferFinal."GST Component Code";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Vendor;
        GenJournalLine."Source No." := TransferHeader."Vendor No.";
        GenJournalLine."Location Code" := TransferHeader."Transfer-from Code";
        GenJournalLine."Source Code" := SourceCodeSetup.Transfer;
        if (GenJournalLine.Amount <> 0) then
            RunGenJnlPostLine(GenJournalLine);
    end;

    local procedure GetTransferReceiptPostingNoSeries(var TransferHeader: Record "Transfer Header"): Code[20]
    var
        PostingNoSeries: Record "Posting No. Series";
        NoSeriesCode: Code[20];
    begin
        PostingNoSeries.SetRange("Table Id", Database::"Transfer Header");
        NoSeriesCode := GSTTransferOrderShipment.LoopPostingNoSeries(
            PostingNoSeries,
            TransferHeader,
            PostingNoSeries."Document Type"::"Transfer Receipt Header");
        exit(NoSeriesCode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnRunWithCheckOnAfterRetrieveItemTracking', '', false, false)]
    local procedure OnRunWithCheckOnAfterRetrieveItemTracking(var ItemJournalLine: Record "Item Journal Line"; var TempTrackingSpecification: Record "Tracking Specification"; var TrackingSpecExists: Boolean)
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        if (ItemJournalLine."Source Code" = SourceCodeSetup."Revaluation Journal") and (ItemJournalLine."Applies-to Entry" <> 0) then
            TrackingSpecExists := false;
    end;

    local procedure InitRevaluationEntryGST(var ItemJournalLine: Record "Item Journal Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        SourceCodeSetup.Get();

        if ItemJournalCustom = 0 then
            exit;

        if (ItemJournalLine."Source Code" <> SourceCodeSetup.Transfer) then
            exit;

        if not TransferReceiptLine.Get(ItemJournalLine."Document No.", ItemJournalLine."Document Line No.") then
            exit;

        InitRevaluationEntry(ItemJournalLine, (ItemJournalCustom / TransferReceiptLine."Quantity"));
    end;

    local procedure InitRevaluationEntryUnrealizedProfit(var ItemJournalLine: Record "Item Journal Line"; var ValueEntry: Record "Value Entry")
    var
        SourceCodeSetup: Record "Source Code Setup";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferReceiptLine: Record "Transfer Receipt Line";
        Location: Record Location;
        TransferPriceDiff: Decimal;
        TotalTransferPriceDiff: Decimal;
        AmntUnitCost: Decimal;
    begin
        if not TransferReceiptLine.Get(ItemJournalLine."Document No.", ItemJournalLine."Document Line No.") then
            exit;

        SourceCodeSetup.Get();
        if (ItemJournalLine."Source Code" <> SourceCodeSetup.Transfer) then
            exit;

        TransferHeader.Get(ItemJournalLine."Order No.");
        if not TransferHeader."Load Unreal Prof Amt on Invt." then
            exit;

        Location.Get(TransferHeader."Transfer-from Code");
        if Location."Bonded warehouse" then
            exit;

        TransferLine.Get(ItemJournalLine."Order No.", ItemJournalLine."Order Line No.");

        if TransferLine."Qty. to Receive" = TransferLine.Quantity then
            RoundDiffAmt := TransferLine.Amount - (-TransferCost)
        else
            RoundDiffAmt := Round((TransferLine.Amount / TransferLine.Quantity) * TransferLine."Qty. to Receive", 0.01, '=') - (-TransferCost);
        TotalTransferPriceDiff := 0;

        AmntUnitCost := ValueEntry."Cost Amount (Actual)" / ValueEntry."Item Ledger Entry Quantity";
        TransferPriceDiff := Round((TransferLine."Transfer Price" / ItemJournalLine."Qty. per Unit of Measure") - AmntUnitCost);
        if TransferPriceDiff <> 0 then begin
            TotalTransferPriceDiff += TransferPriceDiff * ItemJournalLine.Quantity;
            if (TotalTransferPriceDiff <> RoundDiffAmt) and (ItemJournalLine."Lot No." = '') then
                TransferPriceDiff := TransferPriceDiff - (TotalTransferPriceDiff - RoundDiffAmt);

            InitRevaluationEntry(ItemJournalLine, TransferPriceDiff);
        end;
    end;

    local procedure InitRevaluationEntry(var ItemJournalLine: Record "Item Journal Line"; UnitCostRevalued: Decimal)
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();

        LineNo := LineNo + 1;

        TempItemJnlLine.Init();
        TempItemJnlLine.Validate("Posting Date", ItemJournalLine."Posting Date");
        TempItemJnlLine.Validate("Document No.", ItemJournalLine."Document No.");
        TempItemJnlLine."External Document No." := ItemJournalLine."External Document No.";
        TempItemJnlLine.Validate("Entry Type", TempItemJnlLine."Entry Type"::Transfer);
        TempItemJnlLine."Value Entry Type" := TempItemJnlLine."Value Entry Type"::Revaluation;
        TempItemJnlLine.Validate("Item No.", ItemJournalLine."Item No.");
        TempItemJnlLine."Source Code" := SourceCodeSetup."Revaluation Journal";
        TempItemJnlLine.Validate("Applies-to Entry", ItemLedgerEntryNo);
        TempItemJnlLine.Validate("Unit Cost (Revalued)", (TempItemJnlLine."Unit Cost (Revalued)" + UnitCostRevalued));
        TempItemJnlLine.Description := StrSubstNo(TransferReceiptNoLbl, ItemJournalLine."Document No.");
        TempItemJnlLine."Line No." := LineNo;
        TempItemJnlLine.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterPostItemJnlLine', '', false, false)]
    local procedure OnAfterPostItemJnlLine(sender: Codeunit "Item Jnl.-Post Line"; var ItemJournalLine: Record "Item Journal Line")
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        if ItemJournalLine."Entry Type" <> ItemJournalLine."Entry Type"::Transfer then
            exit;

        if not TransferReceiptLine.Get(ItemJournalLine."Document No.", ItemJournalLine."Document Line No.") then
            exit;

        if TempItemJnlLine.IsEmpty then
            exit;

        TotalQuantity := TotalQuantity + ItemJournalLine.Quantity;

        if TotalQuantity <> TransferReceiptLine.Quantity then
            exit;

        if TempItemJnlLine.FindSet() then
            repeat
                sender.RunWithCheck(TempItemJnlLine);
            until TempItemJnlLine.Next() = 0;

        TotalQuantity := 0;
        TempItemJnlLine.DeleteAll();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTransRcptLineFillBuffer(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostTransferOrderReceiptGLEntries(var TempTransferBufferFinal: Record "Transfer Buffer" temporary; var TransferHeader: Record "Transfer Header"; var TransferReceiptHeader: Record "Transfer Receipt Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostUnrealizedPorfitAccountEntries(var TempTransferBufferFinal: Record "Transfer Buffer" temporary; var TransferHeader: Record "Transfer Header"; var TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostInventoryEntries(var TempTransferBufferFinal: Record "Transfer Buffer" temporary; var TransferHeader: Record "Transfer Header")
    begin
    end;
}
