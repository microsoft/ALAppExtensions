namespace Microsoft.DataMigration.GP;

using Microsoft.Purchases.Document;
using Microsoft.Inventory.Journal;
using Microsoft.Purchases.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.UOM;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Posting;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Setup;
using System.Integration;

codeunit 40108 "GP PO Migrator"
{
    var
        MigratedFromGPDescriptionTxt: Label 'Migrated from GP';
        GPCodeTxt: Label 'GP', Locked = true;
        ItemJournalBatchNameTxt: Label 'GPPOITEMS', Comment = 'Item journal batch name for item adjustments', Locked = true;
        SimpleInvJnlNameTxt: Label 'DEFAULT', Comment = 'The default name of the item journal', Locked = true;
        ItemJnlBatchLineNo: Integer;
        PostPurchaseOrderNoList: List of [Text];
        InitialAutomaticCostAdjustmentType: Enum "Automatic Cost Adjustment Type";

    procedure MigratePOStagingData()
    var
        GPPOP10100: Record "GP POP10100";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CompanyInformation: Record "Company Information";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
        InventorySetup: Record "Inventory Setup";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseDocumentStatus: Enum "Purchase Document Status";
        CountryCode: Code[10];
    begin
        if InventorySetup.Get() then
            InitialAutomaticCostAdjustmentType := InventorySetup."Automatic Cost Adjustment";

        SetInventoryAutomaticCostAdjustment(false);
        SetDirectCostPostingAccountIfNeeded();
        Clear(ItemJnlBatchLineNo);

        GPPOP10100.SetRange(POTYPE, GPPOP10100.POTYPE::Standard);
        GPPOP10100.SetRange(POSTATUS, 1, 4);
        GPPOP10100.SetFilter(VENDORID, '<>%1', '');
        if not GPPOP10100.FindSet() then
            exit;

        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        CountryCode := CompanyInformation."Country/Region Code";

        repeat
            if Vendor.Get(GPPOP10100.VENDORID) then begin
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPPOP10100.RecordId));

                Clear(PurchaseHeader);
                PurchaseHeader.Validate("Document Type", PurchaseDocumentType::Order);
                PurchaseHeader."No." := GPPOP10100.PONUMBER;
                PurchaseHeader.Status := PurchaseDocumentStatus::Open;
                PurchaseHeader.Insert(true);

                PurchaseHeader.Validate("Buy-from Vendor No.", GPPOP10100.VENDORID);
                PurchaseHeader.Validate("Pay-to Vendor No.", GPPOP10100.VENDORID);
                PurchaseHeader.Validate("Order Date", GPPOP10100.DOCDATE);
                PurchaseHeader.Validate("Posting Date", GPPOP10100.DOCDATE);
                PurchaseHeader.Validate("Document Date", GPPOP10100.DOCDATE);
                PurchaseHeader.Validate("Expected Receipt Date", GPPOP10100.PRMDATE);
                PurchaseHeader.Validate("Posting Description", MigratedFromGPDescriptionTxt);
                PurchaseHeader.Validate("Payment Terms Code", CopyStr(GPPOP10100.PYMTRMID, 1, MaxStrLen(PurchaseHeader."Payment Terms Code")));
                PurchaseHeader."Shipment Method Code" := CopyStr(GPPOP10100.SHIPMTHD, 1, MaxStrLen(PurchaseHeader."Shipment Method Code"));
                PurchaseHeader.Validate("Prices Including VAT", false);
                PurchaseHeader.Validate("Vendor Invoice No.", GPPOP10100.PONUMBER);
                PurchaseHeader.Validate("Gen. Bus. Posting Group", GPCodeTxt);

                UpdateShipToAddress(GPPOP10100, CountryCode, PurchaseHeader);

                if PurchasesPayablesSetup.FindFirst() then begin
                    PurchaseHeader.Validate("Posting No. Series", PurchasesPayablesSetup."Posted Invoice Nos.");
                    PurchaseHeader.Validate("Receiving No. Series", PurchasesPayablesSetup."Posted Receipt Nos.");
                end;

                SetVendorDocumentNo(PurchaseHeader);

                PurchaseHeader.Modify(true);
                CreateLines(PurchaseHeader."No.");

                // If no lines were created, delete the empty Purchase Header
                PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                if PurchaseLine.IsEmpty() then
                    PurchaseHeader.Delete();
            end;
        until GPPOP10100.Next() = 0;

        PostReceivedPurchaseLines();
        SetInventoryAutomaticCostAdjustment(true);
    end;

    local procedure UpdateShipToAddress(GPPOP10100: Record "GP POP10100"; CountryCode: Code[10]; var PurchaseHeader: Record "Purchase Header")
    begin
        if GPPOP10100.PRSTADCD.Trim() <> '' then begin
            PurchaseHeader."Ship-to Code" := CopyStr(DelChr(GPPOP10100.PRSTADCD, '>', ' '), 1, MaxStrLen(PurchaseHeader."Ship-to Code"));
            PurchaseHeader."Ship-to Country/Region Code" := CountryCode;
        end;

        if GPPOP10100.CMPNYNAM.Trim() <> '' then
            PurchaseHeader."Ship-to Name" := GPPOP10100.CMPNYNAM;

        if GPPOP10100.ADDRESS1.Trim() <> '' then
            PurchaseHeader."Ship-to Address" := GPPOP10100.ADDRESS1;

        if GPPOP10100.ADDRESS2.Trim() <> '' then
            PurchaseHeader."Ship-to Address 2" := CopyStr(DelChr(GPPOP10100.ADDRESS2, '>', ' '), 1, MaxStrLen(PurchaseHeader."Ship-to Address 2"));

        if GPPOP10100.CITY.Trim() <> '' then
            PurchaseHeader."Ship-to City" := CopyStr(DelChr(GPPOP10100.CITY, '>', ' '), 1, MaxStrLen(PurchaseHeader."Ship-to City"));

        if GPPOP10100.CONTACT.Trim() <> '' then
            PurchaseHeader."Ship-to Contact" := GPPOP10100.CONTACT;

        if GPPOP10100.ZIPCODE.Trim() <> '' then
            PurchaseHeader."Ship-to Post Code" := GPPOP10100.ZIPCODE;

        if GPPOP10100.STATE.Trim() <> '' then
            PurchaseHeader."Ship-to County" := GPPOP10100.STATE;
    end;

    local procedure CreateLines(PONumber: Code[20])
    var
        GPPOP10110: Record "GP POP10110";
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        GPPOPReceiptApplyLineUnitCost: Record GPPOPReceiptApply;
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        LineQuantityRemaining: Decimal;
        LineNo: Integer;
        LocationCode: Code[10];
        UnitOfMeasure: Code[10];
        LastLocation: Text[12];
        LastLineUnitCost: Decimal;
        LineQtyReceivedByUnitCost: Decimal;
        LineQtyInvoicedByUnitCost: Decimal;
    begin
        GPPOP10110.SetRange(PONUMBER, PONumber);
        if not GPPOP10110.FindSet() then
            exit;

        LineNo := 10000;
        repeat
            LastLocation := '';
            LastLineUnitCost := 0;

            LineQuantityRemaining := GPPOP10110.QTYORDER - GPPOP10110.QTYCANCE;
            if LineQuantityRemaining > 0 then begin
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPPOP10110.RecordId));
                GPPOPReceiptApplyLineUnitCost.SetLoadFields(TRXLOCTN, PCHRPTCT, UOFM);
                GPPOPReceiptApplyLineUnitCost.SetCurrentKey(TRXLOCTN, PCHRPTCT);
                GPPOPReceiptApplyLineUnitCost.SetRange(PONUMBER, GPPOP10110.PONUMBER);
                GPPOPReceiptApplyLineUnitCost.SetRange(POLNENUM, GPPOP10110.ORD);
                GPPOPReceiptApplyLineUnitCost.SetRange(Status, GPPOPReceiptApplyLineUnitCost.Status::Posted);
                GPPOPReceiptApplyLineUnitCost.SetFilter(POPTYPE, '1|3');
                GPPOPReceiptApplyLineUnitCost.SetFilter(QTYSHPPD, '>%1', 0);
                GPPOPReceiptApplyLineUnitCost.SetFilter(PCHRPTCT, '>%1', 0);

                if GPPOPReceiptApplyLineUnitCost.FindSet() then
                    repeat
                        if ((LastLocation <> GPPOPReceiptApplyLineUnitCost.TRXLOCTN) or (LastLineUnitCost <> GPPOPReceiptApplyLineUnitCost.PCHRPTCT)) then begin
                            LocationCode := CopyStr(GPPOPReceiptApplyLineUnitCost.TRXLOCTN, 1, MaxStrLen(LocationCode));
                            UnitOfMeasure := CopyStr(GPPOPReceiptApplyLineUnitCost.UOFM.Trim(), 1, MaxStrLen(UnitOfMeasure));
                            LineQtyReceivedByUnitCost := GPPOPReceiptApply.GetSumQtyShippedByUnitCost(GPPOP10110.PONUMBER, GPPOP10110.ORD, LocationCode, GPPOPReceiptApplyLineUnitCost.PCHRPTCT);
                            LineQtyInvoicedByUnitCost := GPPOPReceiptApply.GetSumQtyInvoicedByUnitCost(GPPOP10110.PONUMBER, GPPOP10110.ORD, LocationCode, GPPOPReceiptApplyLineUnitCost.PCHRPTCT);

                            if (LineQtyReceivedByUnitCost > LineQtyInvoicedByUnitCost) then
                                CreateLine(PONumber, GPPOP10110, LineQuantityRemaining, LineNo, LineQtyReceivedByUnitCost, LineQtyInvoicedByUnitCost, GPPOPReceiptApplyLineUnitCost.PCHRPTCT, LocationCode, UnitOfMeasure)
                            else
                                LineQuantityRemaining := LineQuantityRemaining - LineQtyReceivedByUnitCost;

                            LastLocation := GPPOPReceiptApplyLineUnitCost.TRXLOCTN;
                            LastLineUnitCost := GPPOPReceiptApplyLineUnitCost.PCHRPTCT;
                        end;
                    until GPPOPReceiptApplyLineUnitCost.Next() = 0;

                LocationCode := CopyStr(GPPOP10110.LOCNCODE.Trim(), 1, MaxStrLen(LocationCode));
                UnitOfMeasure := CopyStr(GPPOP10110.UOFM.Trim(), 1, MaxStrLen(UnitOfMeasure));
                if LineQuantityRemaining > 0 then
                    CreateLine(PONumber, GPPOP10110, LineQuantityRemaining, LineNo, 0, 0, GPPOP10110.UNITCOST, LocationCode, UnitOfMeasure);
            end;
        until GPPOP10110.Next() = 0;
    end;

    local procedure CreateLine(PONumber: Code[20]; var GPPOP10110: Record "GP POP10110"; var LineQuantityRemaining: Decimal; var LineNo: Integer; QuantityReceived: Decimal; QuantityInvoiced: Decimal; UnitCost: Decimal; LocationCode: Code[10]; UnitOfMeasure: Code[10])
    var
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseLineType: Enum "Purchase Line Type";
        ItemNo: Code[20];
        IsInventoryItem: Boolean;
        AdjustedQuantity: Decimal;
        AdjustedQuantityReceived: Decimal;
        AdjustedQuantityInvoiced: Decimal;
        QuantityOverReceipt: Decimal;
    begin
        // Not generating an invoice so zero out the Invoice quantity and adjust the other counts accordingly.
        // Update Qty. to Receive to equal the adjusted amount received.
        if QuantityInvoiced > QuantityReceived then
            QuantityInvoiced := QuantityReceived;

        AdjustedQuantityReceived := ZeroIfNegative(QuantityReceived, QuantityInvoiced);
        if AdjustedQuantityReceived > 0 then
            AdjustedQuantity := ZeroIfNegative(QuantityReceived, QuantityInvoiced)
        else
            AdjustedQuantity := ZeroIfNegative(LineQuantityRemaining, QuantityInvoiced);

        QuantityOverReceipt := ZeroIfNegative(AdjustedQuantityReceived, AdjustedQuantity);

        if QuantityOverReceipt > 0 then
            AdjustedQuantity := AdjustedQuantityReceived;

        AdjustedQuantityInvoiced := 0;
        ItemNo := CopyStr(GPPOP10110.ITEMNMBR.Trim(), 1, MaxStrLen(ItemNo));
        IsInventoryItem := false;

        if Item.Get(ItemNo) then
            IsInventoryItem := Item.Type = Item.Type::Inventory;

        PurchaseLine.Init();
        PurchaseLine."Document No." := PONumber;
        PurchaseLine."Document Type" := PurchaseDocumentType::Order;
        PurchaseLine."Line No." := LineNo;
        PurchaseLine."Buy-from Vendor No." := GPPOP10110.VENDORID;
        PurchaseLine.Type := PurchaseLineType::Item;

        if GPPOP10110.NONINVEN = 1 then
            CreateNonInventoryItem(GPPOP10110);

        PurchaseLine.Validate("Gen. Bus. Posting Group", GPCodeTxt);
        PurchaseLine.Validate("Gen. Prod. Posting Group", GPCodeTxt);
        PurchaseLine."Unit of Measure" := UnitOfMeasure;
        PurchaseLine."Unit of Measure Code" := UnitOfMeasure;
        PurchaseLine."Location Code" := LocationCode;
        PurchaseLine.Validate("No.", ItemNo);
        PurchaseLine."Posting Group" := GPCodeTxt;
        PurchaseLine.Validate("Expected Receipt Date", GPPOP10110.PRMDATE);
        PurchaseLine.Description := CopyStr(GPPOP10110.ITEMDESC.Trim(), 1, MaxStrLen(PurchaseLine.Description));

        if QuantityOverReceipt > 0 then begin
            if IsInventoryItem then begin
                CreateOverReceiptCodeIfNeeded(AdjustedQuantityReceived, AdjustedQuantity);
                if Item."Over-Receipt Code" = '' then begin
                    Item.Validate("Over-Receipt Code", GPCodeTxt);
                    Item.Modify();
                end;
            end;

            if not IsInventoryItem then
                QuantityOverReceipt := 0;
        end;

        PurchaseLine.Validate("Quantity Invoiced", AdjustedQuantityInvoiced);
        PurchaseLine.Validate("Quantity", AdjustedQuantity);
        PurchaseLine.Validate("Qty. to Receive", AdjustedQuantityReceived);
        PurchaseLine.Validate("Outstanding Quantity", AdjustedQuantity);
        PurchaseLine.Validate("Direct Unit Cost", UnitCost);
        PurchaseLine.Validate(Amount, UnitCost * AdjustedQuantity);
        PurchaseLine.Validate("Outstanding Amount", PurchaseLine."Outstanding Quantity" * UnitCost);
        PurchaseLine.Validate("Outstanding Amount (LCY)", PurchaseLine."Outstanding Amount");
        PurchaseLine.Validate("Unit Cost", UnitCost);

        if QuantityOverReceipt > 0 then begin
            PurchaseLine."Over-Receipt Code" := GPCodeTxt;
            PurchaseLine."Over-Receipt Quantity" := QuantityOverReceipt;
        end;

        if PurchaseLine."Outstanding Quantity" > 0 then
            PurchaseLine.Validate("Outstanding Qty. (Base)", PurchaseLine."Outstanding Quantity");

        PurchaseLine."Line Amount" := PurchaseLine.Amount;

        if PurchaseLine.Quantity > 0 then begin
            PurchaseLine.Insert(true);

            if IsInventoryItem and (PurchaseLine."Qty. to Receive (Base)" > 0) then begin
                if not PostPurchaseOrderNoList.Contains(PONumber) then
                    PostPurchaseOrderNoList.Add(PONumber);

                CreateNegativeAdjustment(PurchaseLine);
            end;

            LineNo := LineNo + 10000;
        end;
        LineQuantityRemaining := LineQuantityRemaining - QuantityReceived;
    end;

    local procedure CreateNonInventoryItem(GPPOP10110: Record "GP POP10110")
    var
        NewItem: Record Item;
        UnitOfMeasureRec: Record "Unit of Measure";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        ItemType: Enum "Item Type";
        ItemNo: Code[20];
        UnitOfMeasure: Code[10];
    begin
        ItemNo := CopyStr(GPPOP10110.ITEMNMBR, 1, MaxStrLen(ItemNo));
        NewItem.SetRange("No.", ItemNo);
        if not NewItem.IsEmpty() then
            exit;

        UnitOfMeasure := UpperCase(CopyStr(GPPOP10110.UOFM, 1, MaxStrLen(UnitOfMeasure)));
        if not UnitOfMeasureRec.Get(UnitOfMeasure) then begin
            UnitOfMeasureRec.Validate(Code, UnitOfMeasure);
            UnitOfMeasureRec.Validate(Description, GPPOP10110.UOFM);
            UnitOfMeasureRec.Insert(true);
        end;

        if not GenProductPostingGroup.Get(GPCodeTxt) then begin
            GenProductPostingGroup.Code := GPCodeTxt;
            GenProductPostingGroup.Description := MigratedFromGPDescriptionTxt;
            GenProductPostingGroup.Insert();
        end;

        NewItem.Init();
        NewItem.Validate("No.", ItemNo);
        NewItem.Validate(Description, CopyStr(GPPOP10110.ITEMDESC, 1, MaxStrLen(NewItem.Description)));
        NewItem.Validate(Type, ItemType::"Non-Inventory");
        NewItem.Validate("Unit Cost", GPPOP10110.UNITCOST);
        NewItem.Validate("Gen. Prod. Posting Group", GPCodeTxt);
        NewItem.Insert(true);

        NewItem.Validate("Base Unit of Measure", UnitOfMeasure);
        NewItem.Modify(true);
    end;

    local procedure CreateOverReceiptCodeIfNeeded(QuantityReceived: Decimal; QuantityOrdered: Decimal)
    var
        OverReceiptCode: Record "Over-Receipt Code";
        OveragePercentage: Decimal;
    begin
        OveragePercentage := QuantityReceived / QuantityOrdered;
        if OveragePercentage > 1 then
            OveragePercentage := 1;

        if not OverReceiptCode.Get(GPCodeTxt) then begin
            OverReceiptCode.Validate(Code, GPCodeTxt);
            OverReceiptCode.Validate(Description, MigratedFromGPDescriptionTxt);
            OverReceiptCode.Validate("Over-Receipt Tolerance %", OveragePercentage * 100);
            OverReceiptCode.Insert(true);
        end else
            if OverReceiptCode."Over-Receipt Tolerance %" < OveragePercentage * 100 then begin
                OverReceiptCode.Validate("Over-Receipt Tolerance %", OveragePercentage * 100);
                OverReceiptCode.Modify();
            end;
    end;

    local procedure CreateNegativeAdjustment(var PurchaseLine: Record "Purchase Line")
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalBatch: Record "Item Journal Batch";
        AdjustItemInventory: Codeunit "Adjust Item Inventory";
        ItemTemplateName: Code[10];
    begin
        ItemTemplateName := AdjustItemInventory.SelectItemTemplateForAdjustment();

        if not ItemJournalBatch.Get(ItemTemplateName, ItemJournalBatchNameTxt) then begin
            ItemJournalBatch."Journal Template Name" := ItemTemplateName;
            ItemJournalBatch.Name := ItemJournalBatchNameTxt;
            ItemJournalBatch.Description := SimpleInvJnlNameTxt;
            ItemJournalBatch.Insert();
        end;

        ItemJnlBatchLineNo := ItemJnlBatchLineNo + 1;

        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", ItemTemplateName);
        ItemJournalLine.Validate("Journal Batch Name", ItemJournalBatchNameTxt);
        ItemJournalLine.Validate("Posting Date", PurchaseLine.GetDate());
        ItemJournalLine.Validate("Document No.", PurchaseLine."Document No.");
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Negative Adjmt.");
        ItemJournalLine.Validate("Item No.", PurchaseLine."No.");
        ItemJournalLine.Validate("Line No.", ItemJnlBatchLineNo);
        ItemJournalLine.Validate(Description, PurchaseLine.Description);
        ItemJournalLine.Validate(Quantity, PurchaseLine."Qty. to Receive");
        ItemJournalLine."Location Code" := PurchaseLine."Location Code";
        ItemJournalLine."Unit Cost" := PurchaseLine."Unit Cost";
        ItemJournalLine.Insert(true);
    end;

    local procedure PostReceivedPurchaseLines()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        ItemNo: Code[20];
        ItemTrackingCode: Code[10];
        PurchaseOrderNo: Text;
        ItemTrackingDictionary: Dictionary of [Code[20], Code[10]];
    begin
        foreach PurchaseOrderNo in PostPurchaseOrderNoList do
            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseOrderNo) then begin
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(PurchaseHeader.RecordId));
                PurchaseHeader.Receive := true;
                PurchaseHeader.Modify();

                // Reset item tracking for received lines. 
                // The item transaction has already been recorded by the GP Item Migrator part of the migration, and posting will fail here without this.
                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchaseLine.SetFilter("Qty. to Receive", '>%1', 0);
                if PurchaseLine.FindSet() then
                    repeat
                        if not ItemTrackingDictionary.ContainsKey(PurchaseLine."No.") then
                            if Item.Get(PurchaseLine."No.") then
                                if Item."Item Tracking Code" <> '' then begin
                                    ItemTrackingDictionary.Add(Item."No.", Item."Item Tracking Code");
                                    Item."Item Tracking Code" := '';
                                    Item.Modify();
                                end;
                    until PurchaseLine.Next() = 0;

                Codeunit.Run(Codeunit::"Purch.-Post", PurchaseHeader);
            end;

        PostItemAdjustments();

        // Set the item tracking back
        Clear(ItemTrackingCode);
        foreach ItemNo in ItemTrackingDictionary.Keys do
            if ItemTrackingDictionary.Get(ItemNo, ItemTrackingCode) then
                if Item.Get(ItemNo) then begin
                    Item."Item Tracking Code" := ItemTrackingCode;
                    Item.Modify();
                end;
    end;

    local procedure PostItemAdjustments()
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatchNameTxt);
        if ItemJournalLine.FindSet() then
            Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJournalLine);

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatchNameTxt);
        if ItemJournalLine.Count() <= 1 then begin
            ItemJournalLine.DeleteAll();

            ItemJournalBatch.SetRange("Name", ItemJournalBatchNameTxt);
            ItemJournalBatch.DeleteAll();
        end;
    end;

    local procedure SetVendorDocumentNo(var PurchaseHeader: Record "Purchase Header")
    var
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        GPPOPReceiptHist: Record GPPOPReceiptHist;
    begin
        GPPOPReceiptApply.SetRange(PONUMBER, PurchaseHeader."No.");
        GPPOPReceiptApply.SetRange(Status, GPPOPReceiptApply.Status::Posted);
        if GPPOPReceiptApply.FindFirst() then begin
            GPPOPReceiptHist.SetRange(POPRCTNM, GPPOPReceiptApply.POPRCTNM);
            GPPOPReceiptHist.SetFilter(VNDDOCNM, '<>%1', '');
            if GPPOPReceiptHist.FindFirst() then
                PurchaseHeader."Vendor Invoice No." := CopyStr(GPPOPReceiptHist.VNDDOCNM.Trim(), 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
        end;
    end;

    local procedure SetDirectCostPostingAccountIfNeeded()
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if GeneralPostingSetup.Get('', GPCodeTxt) then
            if (GeneralPostingSetup."Direct Cost Applied Account" = '') then
                if (GeneralPostingSetup."Inventory Adjmt. Account" <> '') then begin
                    GeneralPostingSetup."Direct Cost Applied Account" := GeneralPostingSetup."Inventory Adjmt. Account";
                    GeneralPostingSetup.Modify();
                end;

        if GeneralPostingSetup.Get(GPCodeTxt, GPCodeTxt) then
            if (GeneralPostingSetup."Direct Cost Applied Account" = '') then
                if (GeneralPostingSetup."Inventory Adjmt. Account" <> '') then begin
                    GeneralPostingSetup."Direct Cost Applied Account" := GeneralPostingSetup."Inventory Adjmt. Account";
                    GeneralPostingSetup.Modify();
                end;
    end;

    local procedure SetInventoryAutomaticCostAdjustment(Enabled: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
        AutomaticCostAdjustmentType: Enum "Automatic Cost Adjustment Type";
    begin
        if InventorySetup.Get() then begin
            if not Enabled then
                InventorySetup."Automatic Cost Adjustment" := AutomaticCostAdjustmentType::Never
            else
                InventorySetup."Automatic Cost Adjustment" := InitialAutomaticCostAdjustmentType;

            InventorySetup.Modify();
        end;
    end;

    local procedure ZeroIfNegative(Minuend: Decimal; Subtrahend: Decimal): Decimal
    var
        Difference: Decimal;
    begin
        Difference := Minuend - Subtrahend;

        if Difference < 0 then
            Difference := 0;

        exit(Difference);
    end;
}