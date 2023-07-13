codeunit 40108 "GP PO Migrator"
{
    var
        MigratedFromGPDescriptionTxt: Label 'Migrated from GP';
        GPCodeTxt: Label 'GP', Locked = true;
        ItemJournalBatchNameTxt: Label 'GPPOITEMS', Comment = 'Item journal batch name for item adjustments', Locked = true;
        SimpleInvJnlNameTxt: Label 'DEFAULT', Comment = 'The default name of the item journal', Locked = true;
        ItemJnlBatchLineNo: Integer;
        PostPurchaseOrderNoList: List of [Text];

    procedure MigratePOStagingData()
    var
        GPPOP10100: Record "GP POP10100";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CompanyInformation: Record "Company Information";
        PurchaseHeader: Record "Purchase Header";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Vendor: Record Vendor;
        HelperFunctions: Codeunit "Helper Functions";
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseDocumentStatus: Enum "Purchase Document Status";
        CountryCode: Code[10];
        CurrencyCode: Code[10];
    begin
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
                CurrencyCode := CopyStr(GPPOP10100.CURNCYID.Trim(), 1, MaxStrLen(CurrencyCode));
                HelperFunctions.CreateCurrencyIfNeeded(CurrencyCode);

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

                if CurrencyCode <> '' then
                    if CurrencyCode <> GeneralLedgerSetup."LCY Code" then
                        if GPPOP10100.XCHGRATE <> 0 then begin
                            if not CurrencyExchangeRate.Get(CurrencyCode, GPPOP10100.EXCHDATE) then begin
                                Clear(CurrencyExchangeRate);
                                CurrencyExchangeRate.Validate("Currency Code", CurrencyCode);
                                CurrencyExchangeRate.Validate("Starting Date", GPPOP10100.EXCHDATE);
                                CurrencyExchangeRate.Validate("Exchange Rate Amount", GPPOP10100.XCHGRATE);
                                CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", GPPOP10100.XCHGRATE);
                                CurrencyExchangeRate.Insert();
                            end;

                            PurchaseHeader."Currency Factor" := GPPOP10100.XCHGRATE;
                            PurchaseHeader."Currency Code" := CurrencyCode;
                        end;

                UpdateShipToAddress(GPPOP10100, CountryCode, PurchaseHeader);

                if PurchasesPayablesSetup.FindFirst() then begin
                    PurchaseHeader.Validate("Posting No. Series", PurchasesPayablesSetup."Posted Invoice Nos.");
                    PurchaseHeader.Validate("Receiving No. Series", PurchasesPayablesSetup."Posted Receipt Nos.");
                end;

                SetVendorDocumentNo(PurchaseHeader);

                PurchaseHeader.Modify(true);
                CreateLines(PurchaseHeader, GPPOP10100);
            end;
        until GPPOP10100.Next() = 0;

        PostReceivedPurchaseLines();
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

    local procedure CreateLines(var PurchaseHeader: Record "Purchase Header"; GPPOP10100: Record "GP POP10100")
    var
        GPPOP10110: Record "GP POP10110";
        PurchaseLine: Record "Purchase Line";
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        Item: Record Item;
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseLineType: Enum "Purchase Line Type";
        ItemNo: Code[20];
        IsInventoryItem: Boolean;
        LineNo: Integer;
        ActualQuantity: Decimal;
        ActualQtyShipped: Decimal;
        ActualQtyInvoiced: Decimal;
        AdjustedQuantity: Decimal;
        AdjustedQtyShipped: Decimal;
        AdjustedQtyInvoiced: Decimal;
        QtyOverReceipt: Decimal;
    begin
        GPPOP10110.SetRange(PONUMBER, GPPOP10100.PONUMBER);
        if not GPPOP10110.FindSet() then
            exit;

        LineNo := 10000;
        repeat
            // Actual counts from GP
            ActualQuantity := GPPOP10110.QTYORDER - GPPOP10110.QTYCANCE;
            ActualQtyShipped := GPPOPReceiptApply.GetSumQtyShipped(GPPOP10110.PONUMBER, GPPOP10110.ORD);
            ActualQtyInvoiced := GPPOPReceiptApply.GetSumQtyInvoiced(GPPOP10110.PONUMBER, GPPOP10110.ORD);

            // Adjust the counts to be in an initial ordered state.
            // Not generating an invoice so zero out the Invoice quantity and adjust the other counts accordingly.
            // Update Qty. to Receive to equal the adjusted amount received.
            if ActualQtyInvoiced > ActualQtyShipped then
                ActualQtyInvoiced := ActualQtyShipped;

            AdjustedQtyShipped := ZeroIfNegative(ActualQtyShipped, ActualQtyInvoiced);
            AdjustedQuantity := ZeroIfNegative(ActualQuantity, ActualQtyInvoiced);
            QtyOverReceipt := ZeroIfNegative(AdjustedQtyShipped, AdjustedQuantity);

            if QtyOverReceipt > 0 then
                AdjustedQuantity := AdjustedQtyShipped;

            AdjustedQtyInvoiced := 0;
            ItemNo := CopyStr(GPPOP10110.ITEMNMBR, 1, MaxStrLen(ItemNo));
            IsInventoryItem := false;

            if Item.Get(ItemNo) then
                IsInventoryItem := Item.Type = Item.Type::Inventory;

            PurchaseLine.Init();
            PurchaseLine."Document No." := CopyStr(GPPOP10110.PONUMBER.Trim(), 1, MaxStrLen(PurchaseLine."Document No."));
            PurchaseLine."Document Type" := PurchaseDocumentType::Order;
            PurchaseLine."Line No." := LineNo;
            PurchaseLine."Buy-from Vendor No." := GPPOP10110.VENDORID;
            PurchaseLine.Type := PurchaseLineType::Item;

            if GPPOP10110.NONINVEN = 1 then
                CreateNonInventoryItem(GPPOP10110);

            PurchaseLine.Validate("Gen. Bus. Posting Group", GPCodeTxt);
            PurchaseLine.Validate("Gen. Prod. Posting Group", GPCodeTxt);
            PurchaseLine."Unit of Measure" := GPPOP10110.UOFM;
            PurchaseLine."Unit of Measure Code" := GPPOP10110.UOFM;
            PurchaseLine.Validate("No.", ItemNo);
            PurchaseLine."Location Code" := CopyStr(GPPOP10110.LOCNCODE, 1, MaxStrLen(PurchaseLine."Location Code"));
            PurchaseLine."Posting Group" := GPCodeTxt;
            PurchaseLine.Validate("Expected Receipt Date", GPPOP10110.PRMDATE);
            PurchaseLine.Description := CopyStr(GPPOP10110.ITEMDESC, 1, MaxStrLen(PurchaseLine.Description));

            if QtyOverReceipt > 0 then begin
                if IsInventoryItem then begin
                    CreateOverReceiptCodeIfNeeded(AdjustedQtyShipped, AdjustedQuantity);
                    if Item."Over-Receipt Code" = '' then begin
                        Item.Validate("Over-Receipt Code", GPCodeTxt);
                        Item.Modify();
                    end;
                end;

                if not IsInventoryItem then
                    QtyOverReceipt := 0;
            end;

            PurchaseLine.Validate("Quantity Invoiced", AdjustedQtyInvoiced);
            PurchaseLine.Validate("Quantity", AdjustedQuantity);
            PurchaseLine.Validate("Qty. to Receive", AdjustedQtyShipped);
            PurchaseLine.Validate("Outstanding Quantity", AdjustedQuantity);
            PurchaseLine.Validate("Direct Unit Cost", GPPOP10110.UNITCOST);
            PurchaseLine.Validate(Amount, GPPOP10110.EXTDCOST);
            PurchaseLine.Validate("Outstanding Amount", PurchaseLine."Outstanding Quantity" * GPPOP10110.UNITCOST);
            PurchaseLine.Validate("Outstanding Amount (LCY)", PurchaseLine."Outstanding Amount");
            PurchaseLine.Validate("Unit Cost", GPPOP10110.UNITCOST);

            if QtyOverReceipt > 0 then begin
                PurchaseLine."Over-Receipt Code" := GPCodeTxt;
                PurchaseLine."Over-Receipt Quantity" := QtyOverReceipt;
            end;

            if PurchaseLine."Outstanding Quantity" > 0 then
                PurchaseLine.Validate("Outstanding Qty. (Base)", PurchaseLine."Outstanding Quantity");

            PurchaseLine."Line Amount" := PurchaseLine.Amount;
            PurchaseLine.Insert(true);

            if IsInventoryItem and (PurchaseLine."Qty. to Receive (Base)" > 0) then begin
                if not PostPurchaseOrderNoList.Contains(PurchaseHeader."No.") then
                    PostPurchaseOrderNoList.Add(PurchaseHeader."No.");

                CreateNegativeAdjustment(PurchaseLine);
            end;

            LineNo := LineNo + 10000;
        until GPPOP10110.Next() = 0;
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

        if not GenProductPostingGroup.get(GPCodeTxt) then begin
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
        ItemJournalLine.Insert(true);
    end;

    local procedure PostReceivedPurchaseLines()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        ItemNo: Code[20];
        ItemTrackingCode: Code[10];
        PurchaseOrderNo: Text;
        ItemTrackingDictionary: Dictionary of [Code[20], Code[10]];
    begin
        foreach PurchaseOrderNo in PostPurchaseOrderNoList do
            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseOrderNo) then begin
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
        if not ItemJournalLine.IsEmpty() then
            ItemJournalLine.DeleteAll();

        ItemJournalBatch.SetRange("Name", ItemJournalBatchNameTxt);
        ItemJournalBatch.DeleteAll();
    end;

    local procedure SetVendorDocumentNo(var PurchaseHeader: Record "Purchase Header")
    var
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        GPPOPReceiptHist: Record GPPOPReceiptHist;
    begin
        GPPOPReceiptApply.SetRange(PONUMBER, PurchaseHeader."No.");
        GPPOPReceiptApply.SetFilter(Status, '%1', GPPOPReceiptApply.Status::Posted);
        if GPPOPReceiptApply.FindFirst() then begin
            GPPOPReceiptHist.SetRange(POPRCTNM, GPPOPReceiptApply.POPRCTNM);
            GPPOPReceiptHist.SetFilter(VNDDOCNM, '<>%1', '');
            if GPPOPReceiptHist.FindFirst() then
                PurchaseHeader."Vendor Invoice No." := CopyStr(GPPOPReceiptHist.VNDDOCNM.Trim(), 1, MaxStrLen(PurchaseHeader."Vendor Invoice No."));
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