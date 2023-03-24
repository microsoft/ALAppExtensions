codeunit 40108 "GP PO Migrator"
{
    var
        MigratedFromGPDescriptionTxt: Label 'Migrated from GP';
        GPCodeTxt: Label 'GP', Locked = true;

    procedure MigratePOStagingData()
    var
        GPPOP10100: Record "GP POP10100";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CompanyInformation: Record "Company Information";
        PurchaseHeader: Record "Purchase Header";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        HelperFunctions: Codeunit "Helper Functions";
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseDocumentStatus: Enum "Purchase Document Status";
        CountryCode: Code[10];
        CurrencyCode: Code[10];
    begin
        GPPOP10100.SetRange(POTYPE, GPPOP10100.POTYPE::Standard);
        GPPOP10100.SetRange(POSTATUS, 1, 4);
        if not GPPOP10100.FindSet() then
            exit;

        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        CountryCode := CompanyInformation."Country/Region Code";

        repeat
            if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, GPPOP10100.PONUMBER) then begin
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
                PurchaseHeader."Vendor Posting Group" := GPCodeTxt;
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
                CreateLines(GPPOP10100);
            end;
        until GPPOP10100.Next() = 0;
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

    local procedure CreateLines(GPPOP10100: Record "GP POP10100")
    var
        GPPOP10110: Record "GP POP10110";
        PurchaseLine: Record "Purchase Line";
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseLineType: Enum "Purchase Line Type";
        LineNo: Integer;
        QtyShipped: Decimal;
    begin
        GPPOP10110.SetRange(PONUMBER, GPPOP10100.PONUMBER);
        if not GPPOP10110.FindSet() then
            exit;

        LineNo := 10000;

        repeat
            PurchaseLine.Init();
            PurchaseLine."Document No." := GPPOP10110.PONUMBER;
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
            PurchaseLine.Validate("No.", CopyStr(GPPOP10110.ITEMNMBR, 1, MaxStrLen(PurchaseLine."No.")));
            PurchaseLine."Location Code" := CopyStr(GPPOP10110.LOCNCODE, 1, MaxStrLen(PurchaseLine."Location Code"));
            PurchaseLine."Posting Group" := GPCodeTxt;
            PurchaseLine.Validate("Expected Receipt Date", GPPOP10110.PRMDATE);
            PurchaseLine.Description := CopyStr(GPPOP10110.ITEMDESC, 1, MaxStrLen(PurchaseLine.Description));

            QtyShipped := GPPOPReceiptApply.GetSumQtyShipped(GPPOP10110.PONUMBER, GPPOP10110.ORD);

            PurchaseLine."Quantity Received" := QtyShipped;
            PurchaseLine."Qty. Received (Base)" := QtyShipped;
            PurchaseLine."Quantity Invoiced" := GPPOPReceiptApply.GetSumQtyInvoiced(GPPOP10110.PONUMBER, GPPOP10110.ORD);
            PurchaseLine.Validate("Quantity (Base)", GPPOP10110.QTYORDER - GPPOP10110.QTYCANCE);            
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

            if QtyShipped > (GPPOP10110.QTYORDER - GPPOP10110.QTYCANCE) then
                ProcessOverReceipt(PurchaseLine, QtyShipped - (GPPOP10110.QTYORDER - GPPOP10110.QTYCANCE));

            PurchaseLine.Validate("Qty. to Receive (Base)", PurchaseLine."Outstanding Quantity");
            PurchaseLine.Validate("Qty. Invoiced (Base)", PurchaseLine."Quantity Invoiced");            
            PurchaseLine.Validate("Outstanding Qty. (Base)", PurchaseLine."Outstanding Quantity");
            PurchaseLine.Validate("Qty. to Invoice (Base)", PurchaseLine."Quantity (Base)" - PurchaseLine."Quantity Invoiced");

            if PurchaseLine.Amount > 0 then
                PurchaseLine.Validate("Line Amount", PurchaseLine.Amount)
            else
                PurchaseLine."Line Amount" := PurchaseLine.Amount;

            PurchaseLine.Modify(true);
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

    local procedure ProcessOverReceipt(var PurchaseLine: Record "Purchase Line"; OverReceiptQty: Decimal)
    var
        OverReceiptCode: Record "Over-Receipt Code";
        PurchaseHeader: Record "Purchase Header";
        PurchaseDocumentStatus: Enum "Purchase Document Status";
        OveragePercentage: Decimal;
    begin
        OveragePercentage := OverReceiptQty / PurchaseLine.Quantity;
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

        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseLine."Document No.") then begin
            PurchaseHeader.Validate(Status, PurchaseDocumentStatus::Released);
            PurchaseHeader.Modify();

            PurchaseLine.Validate("Over-Receipt Code", GPCodeTxt);
            PurchaseLine.Validate("Over-Receipt Quantity", OverReceiptQty);
            PurchaseLine.Modify();

            PurchaseHeader.Validate(Status, PurchaseDocumentStatus::Open);
            PurchaseHeader.Modify();
        end;
    end;
}