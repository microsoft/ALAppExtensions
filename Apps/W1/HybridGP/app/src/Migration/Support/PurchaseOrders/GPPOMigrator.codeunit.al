codeunit 40108 "GP PO Migrator"
{
    Permissions = tabledata "Gen. Product Posting Group" = RIMD,
                    tabledata "General Posting Setup" = RIMD,
                    tabledata Item = RIMD,
                    tabledata "Item Journal Batch" = RIMD,
                    tabledata "Item Journal Line" = RIMD,
                    tabledata "Item Journal Template" = RIMD,
                    tabledata "Item Ledger Entry" = RIMD,
                    tabledata "Over-Receipt Code" = RIMD,
                    tabledata "Purch. Rcpt. Header" = RIMD,
                    tabledata "Purch. Rcpt. Line" = RIMD,
                    tabledata "Purchase Header" = RIMD,
                    tabledata "Purchase Line" = RIMD,
                    tabledata "Unit of Measure" = RIMD,
                    tabledata "Value Entry" = RIMD;

    var
        MigratedFromGPDescriptionTxt: Label 'Migrated from GP';
        GPCodeTxt: Label 'GP', Locked = true;
        PurchBatchNameTxt: Label 'GPPURCH', Locked = true;
        AdjustmentReasonLbl: Label 'Adjustment during GP migration for PO receipt';

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
        SetDirectCostPostingAccountIfNeeded();

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

                PurchaseHeader.Modify(true);
                CreateLines(PurchaseHeader, GPPOP10100);
            end;
        until GPPOP10100.Next() = 0;

        RemoveBatch();
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
        Quantity: Decimal;
        QtyShipped: Decimal;
        QtyInvoiced: Decimal;
        QtyToInvoice: Decimal;
        QtyOverReceipt: Decimal;
    begin
        GPPOP10110.SetRange(PONUMBER, GPPOP10100.PONUMBER);
        if not GPPOP10110.FindSet() then
            exit;

        LineNo := 10000;
        repeat
            Quantity := GPPOP10110.QTYORDER - GPPOP10110.QTYCANCE;
            if Quantity > 0 then begin
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

                QtyShipped := GPPOPReceiptApply.GetSumQtyShipped(GPPOP10110.PONUMBER, GPPOP10110.ORD);
                QtyInvoiced := GPPOPReceiptApply.GetSumQtyInvoiced(GPPOP10110.PONUMBER, GPPOP10110.ORD);
                QtyOverReceipt := QtyShipped - Quantity;

                if QtyOverReceipt > 0 then begin
                    if IsInventoryItem then begin
                        CreateOverReceiptCodeIfNeeded(QtyShipped, Quantity);
                        if Item."Over-Receipt Code" = '' then begin
                            Item.Validate("Over-Receipt Code", GPCodeTxt);
                            Item.Modify();
                        end;
                    end;
                    Quantity := QtyShipped;
                end;

                PurchaseLine."Quantity Received" := QtyShipped;
                PurchaseLine."Qty. Received (Base)" := QtyShipped;
                PurchaseLine."Quantity Invoiced" := QtyInvoiced;
                PurchaseLine.Validate("Quantity (Base)", Quantity);
                PurchaseLine."Outstanding Quantity" := PurchaseLine."Quantity (Base)" - QtyShipped;
                PurchaseLine.Validate("Direct Unit Cost", GPPOP10110.UNITCOST);
                PurchaseLine.Validate(Amount, GPPOP10110.EXTDCOST);
                PurchaseLine.Validate("Outstanding Amount", PurchaseLine."Outstanding Quantity" * GPPOP10110.UNITCOST);
                PurchaseLine."Qty. Rcd. Not Invoiced" := QtyShipped - PurchaseLine."Quantity Invoiced";
                PurchaseLine.Validate("Amt. Rcd. Not Invoiced", PurchaseLine."Qty. Rcd. Not Invoiced" * GPPOP10110.UNITCOST);
                PurchaseLine."Outstanding Amount (LCY)" := PurchaseLine."Outstanding Amount";
                PurchaseLine."Amt. Rcd. Not Invoiced (LCY)" := PurchaseLine."Amt. Rcd. Not Invoiced";
                PurchaseLine."Unit Cost" := GPPOP10110.UNITCOST;
                PurchaseLine.Insert(true);

                if IsInventoryItem and (QtyOverReceipt > 0) then
                    ProcessOverReceipt(PurchaseLine, QtyOverReceipt);

                if PurchaseLine."Outstanding Quantity" > 0 then begin
                    PurchaseLine.Validate("Qty. to Receive (Base)", PurchaseLine."Outstanding Quantity");
                    PurchaseLine.Validate("Outstanding Qty. (Base)", PurchaseLine."Outstanding Quantity");
                end else begin
                    PurchaseLine.Validate("Qty. to Receive (Base)", 0);
                    PurchaseLine.Validate("Outstanding Qty. (Base)", 0);
                end;

                QtyToInvoice := PurchaseLine."Quantity Received" - PurchaseLine."Quantity Invoiced";
                if QtyToInvoice < 0 then
                    QtyToInvoice := 0;

                PurchaseLine.Validate("Qty. Invoiced (Base)", PurchaseLine."Quantity Invoiced");
                PurchaseLine.Validate("Qty. to Invoice (Base)", QtyToInvoice);
                PurchaseLine."Line Amount" := PurchaseLine.Amount;
                PurchaseLine.Modify(true);

                if IsInventoryItem and (PurchaseLine."Quantity Received" > 0) then
                    AppendToPurchaseReceipt(PurchaseHeader, PurchaseLine);

                LineNo := LineNo + 10000;
            end;
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

    local procedure ProcessOverReceipt(var PurchaseLine: Record "Purchase Line"; OverReceiptQty: Decimal)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseDocumentStatus: Enum "Purchase Document Status";
        OriginalQuantity: Decimal;
    begin
        OriginalQuantity := PurchaseLine."Quantity (Base)";
        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseLine."Document No.") then begin
            PurchaseHeader.Validate(Status, PurchaseDocumentStatus::Released);
            PurchaseHeader.Modify();

            PurchaseLine.Validate("Over-Receipt Code", GPCodeTxt);
            PurchaseLine.Validate("Over-Receipt Quantity", OverReceiptQty);
            PurchaseLine.Validate("Quantity (Base)", OriginalQuantity);
            PurchaseLine.Modify();

            PurchaseHeader.Validate(Status, PurchaseDocumentStatus::Open);
            PurchaseHeader.Modify();
        end;
    end;

    local procedure AppendToPurchaseReceipt(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        ReceiptNumber: Code[20];
        PostingDate: Date;
    begin
        ReceiptNumber := PurchaseHeader."No.";
        PostingDate := Today();

        GPPOPReceiptApply.SetRange(PONUMBER, PurchaseHeader."No.");
        GPPOPReceiptApply.SetFilter(POPRCTNM, '<>%1', '');
        if GPPOPReceiptApply.FindLast() then begin
            ReceiptNumber := GPPOPReceiptApply.POPRCTNM;
            PostingDate := GPPOPReceiptApply.DATERECD;

            if PostingDate < PurchaseHeader."Order Date" then
                PostingDate := Today();
        end;

        if not PurchRcptHeader.Get(ReceiptNumber) then begin
            PurchRcptHeader.Validate("No.", ReceiptNumber);
            PurchRcptHeader.Validate("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
            PurchRcptHeader.Validate("Buy-from Vendor Name", PurchaseHeader."Buy-from Vendor Name");
            PurchRcptHeader.Validate("Vendor Posting Group", PurchaseHeader."Vendor Posting Group");
            PurchRcptHeader.Validate("Location Code", PurchaseHeader."Location Code");
            PurchRcptHeader.Validate("Posting Date", PurchaseHeader."Posting Date");
            PurchRcptHeader.Validate("Order Date", PurchaseHeader."Order Date");
            PurchRcptHeader.Validate("Document Date", PurchaseHeader."Document Date");
            PurchRcptHeader.Validate("Payment Terms Code", PurchaseHeader."Payment Terms Code");
            PurchRcptHeader.Validate("Due Date", PurchaseHeader."Due Date");
            PurchRcptHeader.Validate("Currency Code", PurchaseHeader."Currency Code");
            PurchRcptHeader.Validate("Payment Method Code", PurchaseHeader."Payment Method Code");
            PurchRcptHeader.Validate("Order No.", PurchaseHeader."No.");
            PurchRcptHeader.Insert(true);
        end;

        if not PurchRcptLine.Get(PurchRcptHeader."No.", PurchaseLine."Line No.") then begin
            PurchRcptLine.Validate("Document No.", PurchRcptHeader."No.");
            PurchRcptLine.Validate("Order No.", PurchaseLine."Document No.");
            PurchRcptLine.Validate("Line No.", PurchaseLine."Line No.");
            PurchRcptLine.Validate("Order Line No.", PurchaseLine."Line No.");
            PurchRcptLine.Validate("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
            PurchRcptLine.Validate("Variant Code", PurchaseLine."Variant Code");
            PurchRcptLine.Validate("Prod. Order No.", PurchaseLine."Prod. Order No.");
            PurchRcptLine.Validate("Buy-from Vendor No.", PurchaseLine."Buy-from Vendor No.");
            PurchRcptLine.Validate(Type, PurchRcptLine.Type::Item);
            PurchRcptLine.Validate("No.", PurchaseLine."No.");
            PurchRcptLine.Validate(Description, PurchaseLine.Description);
            PurchRcptLine.Validate("Posting Group", PurchaseLine."Posting Group");
            PurchRcptLine.Validate("Gen. Bus. Posting Group", PurchaseLine."Gen. Bus. Posting Group");
            PurchRcptLine.Validate("Gen. Prod. Posting Group", PurchaseLine."Gen. Prod. Posting Group");
            PurchRcptLine.Validate("Location Code", PurchaseLine."Location Code");
            PurchRcptLine.Validate("Expected Receipt Date", PurchaseLine."Expected Receipt Date");
            PurchRcptLine.Validate("Quantity", PurchaseLine."Quantity Received");
            PurchRcptLine.Validate("Direct Unit Cost", PurchaseLine."Unit Cost");
            PurchRcptLine.Validate("Qty. Rcd. Not Invoiced", PurchaseLine."Qty. Rcd. Not Invoiced");
            PurchRcptLine.Insert(true);

            if not ItemJournalTemplate.Get(PurchBatchNameTxt) then begin
                ItemJournalTemplate.Validate(Name, PurchBatchNameTxt);
                ItemJournalTemplate.Validate(Type, ItemJournalTemplate.Type::Item);
                ItemJournalTemplate.Validate(Recurring, false);
                ItemJournalTemplate.Insert(true);
            end;

            if not ItemJournalBatch.Get(ItemJournalTemplate.Name, PurchBatchNameTxt) then begin
                ItemJournalBatch.Init();
                ItemJournalBatch.Validate("Journal Template Name", PurchBatchNameTxt);
                ItemJournalBatch.SetupNewBatch();
                ItemJournalBatch.Validate(Name, PurchBatchNameTxt);
                ItemJournalBatch.Validate(Description, PurchBatchNameTxt);
                ItemJournalBatch."No. Series" := '';
                ItemJournalBatch."Posting No. Series" := '';
                ItemJournalBatch.Insert(true);
            end;

            CreateGLEntries(PurchRcptHeader, PurchRcptLine, PurchaseLine, ItemJournalBatch, PurchaseLine."Quantity Received", PostingDate);
            CreateGLEntries(PurchRcptHeader, PurchRcptLine, PurchaseLine, ItemJournalBatch, -PurchaseLine."Quantity Received", PostingDate);
        end;
    end;

    local procedure CreateGLEntries(var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchaseLine: Record "Purchase Line"; var ItemJournalBatch: Record "Item Journal Batch"; Quantity: Decimal; PostingDate: Date)
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        Item: Record Item;
        CostAmount: Decimal;
        ExpectedCostAmount: Decimal;
        UnitCostAmount: Decimal;
        ItemShptEntryNo: Integer;
        BatchLineNo: Integer;
        ValueEntryNo: Integer;
    begin
        Item.Get(PurchaseLine."No.");
        ItemShptEntryNo := 0;
        if ItemLedgerEntry.FindLast() then
            ItemShptEntryNo := ItemLedgerEntry."Entry No." + 1;

        if ItemShptEntryNo = 0 then
            ItemShptEntryNo := 1;

        BatchLineNo := 0;
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        if ItemJournalLine.FindLast() then
            BatchLineNo := ItemJournalLine."Line No." + 1;

        if BatchLineNo = 0 then
            BatchLineNo := 1;

        Clear(ItemJournalLine);
        ItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);

        if Quantity > 0 then
            ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::Purchase)
        else
            ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Negative Adjmt.");

        ItemJournalLine.Validate(Adjustment, true);
        ItemJournalLine.Validate("Posting Date", PostingDate);
        ItemJournalLine.Validate("Document No.", PurchRcptHeader."No.");
        ItemJournalLine.Validate("Line No.", BatchLineNo);
        ItemJournalLine.Validate("Item No.", PurchaseLine."No.");
        ItemJournalLine.Validate("Description", AdjustmentReasonLbl);
        ItemJournalLine.Validate("Location Code", PurchaseLine."Location Code");
        ItemJournalLine.Validate("Quantity", Quantity);
        ItemJournalLine.Validate("Unit Cost", PurchaseLine."Unit Cost");
        ItemJournalLine.Validate("Inventory Posting Group", Item."Inventory Posting Group");
        ItemJournalLine."Item Shpt. Entry No." := ItemShptEntryNo;
        ItemJournalLine.Insert(true);

        Clear(ItemLedgerEntry);
        ItemLedgerEntry.Validate("Document Type", ItemLedgerEntry."Document Type"::"Purchase Receipt");
        ItemLedgerEntry.Validate("Document No.", PurchRcptHeader."No.");
        ItemLedgerEntry.Validate("Document Date", PurchRcptHeader."Document Date");
        ItemLedgerEntry.Validate(Description, AdjustmentReasonLbl);
        ItemLedgerEntry.Validate(Open, true);

        if Quantity > 0 then begin
            ItemLedgerEntry.Validate("Entry Type", ItemLedgerEntry."Entry Type"::Purchase);
            CostAmount := PurchaseLine."Quantity Invoiced" * PurchaseLine."Unit Cost";
            ExpectedCostAmount := PurchaseLine."Quantity Received" * PurchaseLine."Unit Cost";
            UnitCostAmount := PurchaseLine."Unit Cost";
        end else begin
            ItemLedgerEntry.Validate("Entry Type", ItemLedgerEntry."Entry Type"::"Negative Adjmt.");
            CostAmount := -(PurchaseLine."Quantity Invoiced" * PurchaseLine."Unit Cost");
            ExpectedCostAmount := -(PurchaseLine."Quantity Received" * PurchaseLine."Unit Cost");
            UnitCostAmount := -PurchaseLine."Unit Cost";
        end;

        ItemLedgerEntry.Validate("Order Line No.", ItemJournalLine."Line No.");
        ItemLedgerEntry.Validate("Entry No.", ItemShptEntryNo);
        ItemLedgerEntry.Validate("Item No.", PurchaseLine."No.");
        ItemLedgerEntry.Validate("Location Code", PurchaseLine."Location Code");
        ItemLedgerEntry.Validate("Posting Date", PostingDate);
        ItemLedgerEntry.Validate(Quantity, Quantity);

        if Quantity > 0 then begin
            ItemLedgerEntry.Validate("Invoiced Quantity", PurchaseLine."Quantity Invoiced");
            ItemLedgerEntry.Validate("Remaining Quantity", PurchaseLine."Outstanding Quantity");
        end;

        ItemLedgerEntry.Insert(true);

        ValueEntryNo := 0;
        if ValueEntry.FindLast() then
            ValueEntryNo := ValueEntry."Entry No." + 1;

        if ValueEntryNo = 0 then
            ValueEntryNo := 1;

        Clear(ValueEntry);
        ValueEntry.Validate("Entry No.", ValueEntryNo);
        ValueEntry.Validate("Item Ledger Entry Type", ItemLedgerEntry."Entry Type");
        ValueEntry.Validate("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        ValueEntry.Validate("Item Ledger Entry Quantity", Quantity);
        ValueEntry.Validate("Valued Quantity", Quantity);
        ValueEntry.Validate("Item No.", PurchaseLine."No.");
        ValueEntry.Validate("Document Type", ValueEntry."Document Type"::"Purchase Receipt");
        ValueEntry.Validate("Document No.", PurchRcptHeader."No.");
        ValueEntry.Validate(Description, AdjustmentReasonLbl);
        ValueEntry.Validate(Adjustment, ItemJournalLine.Adjustment);
        ValueEntry.Validate("Inventory Posting Group", Item."Inventory Posting Group");
        ValueEntry.Validate("Variant Code", '');
        ValueEntry.Validate("Location Code", PurchaseLine."Location Code");
        ValueEntry.Validate("Posting Date", PostingDate);
        ValueEntry.Validate("Invoiced Quantity", PurchaseLine."Quantity Invoiced");
        ValueEntry.Validate("Cost per Unit", UnitCostAmount);
        ValueEntry.Validate("Cost Amount (Expected)", ExpectedCostAmount);
        ValueEntry.Validate("Cost Amount (Actual)", CostAmount);
        ValueEntry.Validate("Source Type", ValueEntry."Source Type"::Vendor);
        ValueEntry.Validate("Source No.", PurchRcptHeader."Buy-from Vendor No.");
        ValueEntry.Validate("Source Posting Group", PurchRcptHeader."Vendor Posting Group");
        ValueEntry.Validate("Gen. Bus. Posting Group", PurchaseLine."Gen. Bus. Posting Group");
        ValueEntry.Validate("Gen. Prod. Posting Group", PurchaseLine."Gen. Prod. Posting Group");
        ValueEntry.Insert();

        if (PurchRcptLine."Item Rcpt. Entry No." = 0) then begin
            PurchRcptLine.Validate("Item Rcpt. Entry No.", ItemShptEntryNo);
            PurchRcptLine.Modify();
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

    local procedure RemoveBatch()
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        if ItemJournalBatch.Get(PurchBatchNameTxt, PurchBatchNameTxt) then
            ItemJournalBatch.Delete();

        if ItemJournalTemplate.Get(PurchBatchNameTxt) then
            ItemJournalTemplate.Delete();
    end;
}