codeunit 40108 "GP PO Migrator"
{
    var
        MigratedFromGPDescriptionTxt: Label 'Migrated from GP';
        GPCodeTxt: Label 'GP', Locked = true;

    procedure MigratePOStagingData()
    var
        GPPOPPOHeader: Record "GP POPPOHeader";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CompanyInformation: Record "Company Information";
        PurchaseHeader: Record "Purchase Header";
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseDocumentStatus: Enum "Purchase Document Status";
        CountryCode: Code[10];
    begin
        if not GPPOPPOHeader.FindSet() then
            exit;

        CompanyInformation.Get();

        CountryCode := CompanyInformation."Country/Region Code";

        repeat
            if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, GPPOPPOHeader.PONUMBER) then begin
                PurchaseHeader.Validate("Document Type", PurchaseDocumentType::Order);
                PurchaseHeader."No." := GPPOPPOHeader.PONUMBER;
                PurchaseHeader.Status := PurchaseDocumentStatus::Open;
                PurchaseHeader.Insert(true);

                PurchaseHeader.Validate("Buy-from Vendor No.", GPPOPPOHeader.VENDORID);
                PurchaseHeader.Validate("Pay-to Vendor No.", GPPOPPOHeader.VENDORID);
                PurchaseHeader.Validate("Order Date", GPPOPPOHeader.DOCDATE);
                PurchaseHeader.Validate("Posting Date", GPPOPPOHeader.DOCDATE);
                PurchaseHeader.Validate("Document Date", GPPOPPOHeader.DOCDATE);
                PurchaseHeader.Validate("Expected Receipt Date", GPPOPPOHeader.PRMDATE);
                PurchaseHeader.Validate("Posting Description", MigratedFromGPDescriptionTxt);
                PurchaseHeader.Validate("Payment Terms Code", CopyStr(GPPOPPOHeader.PYMTRMID, 1, MaxStrLen(PurchaseHeader."Payment Terms Code")));
                PurchaseHeader."Shipment Method Code" := CopyStr(GPPOPPOHeader.SHIPMTHD, 1, MaxStrLen(PurchaseHeader."Shipment Method Code"));
                PurchaseHeader."Vendor Posting Group" := GPCodeTxt;
                PurchaseHeader.Validate("Prices Including VAT", false);
                PurchaseHeader.Validate("Vendor Invoice No.", GPPOPPOHeader.PONUMBER);
                PurchaseHeader.Validate("Gen. Bus. Posting Group", GPCodeTxt);

                UpdateShipToAddress(GPPOPPOHeader, CountryCode, PurchaseHeader);

                if PurchasesPayablesSetup.FindFirst() then begin
                    PurchaseHeader.Validate("Posting No. Series", PurchasesPayablesSetup."Posted Invoice Nos.");
                    PurchaseHeader.Validate("Receiving No. Series", PurchasesPayablesSetup."Posted Receipt Nos.");
                end;

                PurchaseHeader.Modify(true);
                CreateLines(GPPOPPOHeader);
            end;
        until GPPOPPOHeader.Next() = 0;
    end;

    local procedure UpdateShipToAddress(GPPOPPOHeader: Record "GP POPPOHeader"; CountryCode: Code[10]; var PurchaseHeader: Record "Purchase Header")
    begin
        if GPPOPPOHeader.PRSTADCD.Trim() <> '' then begin
            PurchaseHeader."Ship-to Code" := CopyStr(DelChr(GPPOPPOHeader.PRSTADCD, '>', ' '), 1, MaxStrLen(PurchaseHeader."Ship-to Code"));
            PurchaseHeader."Ship-to Country/Region Code" := CountryCode;
        end;

        if GPPOPPOHeader.CMPNYNAM.Trim() <> '' then
            PurchaseHeader."Ship-to Name" := GPPOPPOHeader.CMPNYNAM;

        if GPPOPPOHeader.ADDRESS1.Trim() <> '' then
            PurchaseHeader."Ship-to Address" := GPPOPPOHeader.ADDRESS1;

        if GPPOPPOHeader.ADDRESS2.Trim() <> '' then
            PurchaseHeader."Ship-to Address 2" := CopyStr(DelChr(GPPOPPOHeader.ADDRESS2, '>', ' '), 1, MaxStrLen(PurchaseHeader."Ship-to Address 2"));

        if GPPOPPOHeader.CITY.Trim() <> '' then
            PurchaseHeader."Ship-to City" := CopyStr(DelChr(GPPOPPOHeader.CITY, '>', ' '), 1, MaxStrLen(PurchaseHeader."Ship-to City"));

        if GPPOPPOHeader.CONTACT.Trim() <> '' then
            PurchaseHeader."Ship-to Contact" := GPPOPPOHeader.CONTACT;

        if GPPOPPOHeader.ZIPCODE.Trim() <> '' then
            PurchaseHeader."Ship-to Post Code" := GPPOPPOHeader.ZIPCODE;

        if GPPOPPOHeader.STATE.Trim() <> '' then
            PurchaseHeader."Ship-to County" := GPPOPPOHeader.STATE;
    end;

    local procedure CreateLines(GPPOPPOHeader: Record "GP POPPOHeader")
    var
        GPPOPPOLine: Record "GP POPPOLine";
        PurchaseLine: Record "Purchase Line";
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseLineType: Enum "Purchase Line Type";
        LineNo: Integer;
        QtyShipped: Decimal;
    begin
        GPPOPPOLine.SetRange(PONUMBER, GPPOPPOHeader.PONUMBER);
        if not GPPOPPOLine.FindSet() then
            exit;

        LineNo := 10000;

        repeat
            PurchaseLine.Init();
            PurchaseLine."Document No." := GPPOPPOLine.PONUMBER;
            PurchaseLine."Document Type" := PurchaseDocumentType::Order;
            PurchaseLine."Line No." := LineNo;
            PurchaseLine."Buy-from Vendor No." := GPPOPPOLine.VENDORID;
            PurchaseLine.Type := PurchaseLineType::Item;

            if GPPOPPOLine.NONINVEN = 1 then
                CreateNonInventoryItem(GPPOPPOLine);

            PurchaseLine.Validate("Gen. Bus. Posting Group", GPCodeTxt);
            PurchaseLine.Validate("Gen. Prod. Posting Group", GPCodeTxt);
            PurchaseLine."Unit of Measure" := GPPOPPOLine.UOFM;
            PurchaseLine."Unit of Measure Code" := GPPOPPOLine.UOFM;
            PurchaseLine.Validate("No.", CopyStr(GPPOPPOLine.ITEMNMBR, 1, MaxStrLen(PurchaseLine."No.")));
            PurchaseLine."Location Code" := CopyStr(GPPOPPOLine.LOCNCODE, 1, MaxStrLen(PurchaseLine."Location Code"));
            PurchaseLine."Posting Group" := GPCodeTxt;
            PurchaseLine.Validate("Expected Receipt Date", GPPOPPOLine.PRMDATE);
            PurchaseLine.Description := CopyStr(GPPOPPOLine.ITEMDESC, 1, MaxStrLen(PurchaseLine.Description));

            QtyShipped := GPPOPReceiptApply.GetSumQtyShipped(GPPOPPOLine.PONUMBER, GPPOPPOLine.ORD);

            PurchaseLine.Validate("Quantity (Base)", GPPOPPOLine.QTYORDER - GPPOPPOLine.QTYCANCE);
            PurchaseLine."Quantity Received" := QtyShipped;
            PurchaseLine."Qty. Received (Base)" := QtyShipped;
            PurchaseLine."Quantity Invoiced" := GPPOPReceiptApply.GetSumQtyInvoiced(GPPOPPOLine.PONUMBER, GPPOPPOLine.ORD);
            PurchaseLine."Outstanding Quantity" := PurchaseLine."Quantity (Base)" - QtyShipped;
            PurchaseLine.Validate("Direct Unit Cost", GPPOPPOLine.UNITCOST);
            PurchaseLine.Validate(Amount, GPPOPPOLine.EXTDCOST);
            PurchaseLine.Validate("Outstanding Amount", PurchaseLine."Outstanding Quantity" * GPPOPPOLine.UNITCOST);
            PurchaseLine."Qty. Rcd. Not Invoiced" := QtyShipped - PurchaseLine."Quantity Invoiced";
            PurchaseLine.Validate("Amt. Rcd. Not Invoiced", PurchaseLine."Qty. Rcd. Not Invoiced" * GPPOPPOLine.UNITCOST);
            PurchaseLine."Outstanding Amount (LCY)" := PurchaseLine."Outstanding Amount";
            PurchaseLine."Amt. Rcd. Not Invoiced (LCY)" := PurchaseLine."Amt. Rcd. Not Invoiced";
            PurchaseLine."Unit Cost" := GPPOPPOLine.UNITCOST;
            PurchaseLine.Insert(true);

            if QtyShipped > (GPPOPPOLine.QTYORDER - GPPOPPOLine.QTYCANCE) then
                ProcessOverReceipt(PurchaseLine, QtyShipped - (GPPOPPOLine.QTYORDER - GPPOPPOLine.QTYCANCE));

            PurchaseLine.Validate("Qty. to Receive (Base)", PurchaseLine."Outstanding Quantity");
            PurchaseLine.Validate("Outstanding Qty. (Base)", PurchaseLine."Outstanding Quantity");
            PurchaseLine.Validate("Qty. to Invoice (Base)", PurchaseLine."Quantity (Base)" - PurchaseLine."Quantity Invoiced");

            if PurchaseLine.Amount > 0 then
                PurchaseLine.Validate("Line Amount", PurchaseLine.Amount)
            else
                PurchaseLine."Line Amount" := PurchaseLine.Amount;

            PurchaseLine.Modify(true);
            LineNo := LineNo + 10000;
        until GPPOPPOLine.Next() = 0;
    end;

    local procedure CreateNonInventoryItem(GPPOPPOLine: Record "GP POPPOLine")
    var
        NewItem: Record Item;
        UnitOfMeasureRec: Record "Unit of Measure";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        ItemType: Enum "Item Type";
        ItemNo: Code[20];
        UnitOfMeasure: Code[10];
    begin
        ItemNo := CopyStr(GPPOPPOLine.ITEMNMBR, 1, MaxStrLen(ItemNo));
        NewItem.SetRange("No.", ItemNo);
        if not NewItem.IsEmpty() then
            exit;

        UnitOfMeasure := UpperCase(CopyStr(GPPOPPOLine.UOFM, 1, MaxStrLen(UnitOfMeasure)));
        if not UnitOfMeasureRec.Get(UnitOfMeasure) then begin
            UnitOfMeasureRec.Validate(Code, UnitOfMeasure);
            UnitOfMeasureRec.Validate(Description, GPPOPPOLine.UOFM);
            UnitOfMeasureRec.Insert(true);
        end;

        if not GenProductPostingGroup.get(GPCodeTxt) then begin
            GenProductPostingGroup.Code := GPCodeTxt;
            GenProductPostingGroup.Description := MigratedFromGPDescriptionTxt;
            GenProductPostingGroup.Insert();
        end;

        NewItem.Init();
        NewItem.Validate("No.", ItemNo);
        NewItem.Validate(Description, CopyStr(GPPOPPOLine.ITEMDESC, 1, MaxStrLen(NewItem.Description)));
        NewItem.Validate(Type, ItemType::"Non-Inventory");
        NewItem.Validate("Unit Cost", GPPOPPOLine.UNITCOST);
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