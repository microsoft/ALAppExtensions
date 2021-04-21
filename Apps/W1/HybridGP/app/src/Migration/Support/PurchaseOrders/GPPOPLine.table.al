table 40103 "GP POPPOLine"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; PONUMBER; Text[18])
        {
            Caption = 'PONUMBER';
            DataClassification = CustomerContent;
        }
        field(2; ORD; Integer)
        {
            Caption = 'ORD';
            DataClassification = CustomerContent;
        }
        field(3; POLNESTA; Option)
        {
            Caption = 'POLNESTA';
            OptionMembers = ,"New","Released","Change Order","Received","Closed","Canceled";
            DataClassification = CustomerContent;
        }
        field(4; POTYPE; Option)
        {
            Caption = 'POTYPE';
            OptionMembers = ,"Standard","Drop-Ship","Blanket","Drop-Ship Blanket";
            DataClassification = CustomerContent;
        }
        field(5; ITEMNMBR; Text[32])
        {
            Caption = 'ITEMNMBR';
            DataClassification = CustomerContent;
        }
        field(6; ITEMDESC; Text[102])
        {
            Caption = 'ITEMDESC';
            DataClassification = CustomerContent;
        }
        field(7; VENDORID; Text[16])
        {
            Caption = 'VENDORID';
            DataClassification = CustomerContent;
        }
        field(8; VNDITNUM; Text[32])
        {
            Caption = 'VNDITNUM';
            DataClassification = CustomerContent;
        }
        field(9; VNDITDSC; Text[102])
        {
            Caption = 'VNDITDSC';
            DataClassification = CustomerContent;
        }
        field(10; NONINVEN; Integer)
        {
            Caption = 'NONINVEN';
            DataClassification = CustomerContent;
        }
        field(11; LOCNCODE; Text[12])
        {
            Caption = 'LOCNCODE';
            DataClassification = CustomerContent;
        }
        field(12; UOFM; Text[10])
        {
            Caption = 'UOFM';
            DataClassification = CustomerContent;
        }
        field(13; UMQTYINB; Decimal)
        {
            Caption = 'UMQTYINB';
            DataClassification = CustomerContent;
        }
        field(14; QTYORDER; Decimal)
        {
            Caption = 'QTYORDER';
            DataClassification = CustomerContent;
        }
        field(15; QTYCANCE; Decimal)
        {
            Caption = 'QTYCANCE';
            DataClassification = CustomerContent;
        }
        field(16; QTYCMTBASE; Decimal)
        {
            Caption = 'QTYCMTBASE';
            DataClassification = CustomerContent;
        }
        field(17; QTYUNCMTBASE; Decimal)
        {
            Caption = 'QTYUNCMTBASE';
            DataClassification = CustomerContent;
        }
        field(18; UNITCOST; Decimal)
        {
            Caption = 'UNITCOST';
            DataClassification = CustomerContent;
        }
        field(19; EXTDCOST; Decimal)
        {
            Caption = 'EXTDCOST';
            DataClassification = CustomerContent;
        }
        field(20; INVINDX; Integer)
        {
            Caption = 'INVINDX';
            DataClassification = CustomerContent;
        }
        field(21; REQDATE; Date)
        {
            Caption = 'REQDATE';
            DataClassification = CustomerContent;
        }
        field(22; PRMDATE; Date)
        {
            Caption = 'PRMDATE';
            DataClassification = CustomerContent;
        }
        field(23; PRMSHPDTE; Date)
        {
            Caption = 'PRMSHPDTE';
            DataClassification = CustomerContent;
        }
        field(24; REQSTDBY; Text[22])
        {
            Caption = 'REQSTDBY';
            DataClassification = CustomerContent;
        }
        field(25; COMMNTID; Text[16])
        {
            Caption = 'COMMNTID';
            DataClassification = CustomerContent;
        }
        field(26; DOCTYPE; Option)
        {
            Caption = 'DOCTYPE';
            OptionMembers = ,"f";
            DataClassification = CustomerContent;
        }
        field(27; POLNEARY_1; Decimal)
        {
            Caption = 'POLNEARY_1';
            DataClassification = CustomerContent;
        }
        field(28; POLNEARY_2; Decimal)
        {
            Caption = 'POLNEARY_2';
            DataClassification = CustomerContent;
        }
        field(29; POLNEARY_3; Decimal)
        {
            Caption = 'POLNEARY_3';
            DataClassification = CustomerContent;
        }
        field(30; POLNEARY_4; Decimal)
        {
            Caption = 'POLNEARY_4';
            DataClassification = CustomerContent;
        }
        field(31; POLNEARY_5; Decimal)
        {
            Caption = 'POLNEARY_5';
            DataClassification = CustomerContent;
        }
        field(32; POLNEARY_6; Decimal)
        {
            Caption = 'POLNEARY_6';
            DataClassification = CustomerContent;
        }
        field(33; POLNEARY_7; Decimal)
        {
            Caption = 'POLNEARY_7';
            DataClassification = CustomerContent;
        }
        field(34; POLNEARY_8; Decimal)
        {
            Caption = 'POLNEARY_8';
            DataClassification = CustomerContent;
        }
        field(35; POLNEARY_9; Decimal)
        {
            Caption = 'POLNEARY_9';
            DataClassification = CustomerContent;
        }
        field(36; DECPLCUR; Option)
        {
            Caption = 'DECPLCUR';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(37; DECPLQTY; Option)
        {
            Caption = 'DECPLQTY';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(38; ITMTRKOP; Option)
        {
            Caption = 'ITMTRKOP';
            OptionMembers = ,"None","Serial Numbers","Lot Numbers";
            DataClassification = CustomerContent;
        }
        field(39; VCTNMTHD; Option)
        {
            Caption = 'VCTNMTHD';
            OptionMembers = ,"FIFO Perpetual","LIFO Perpetual","Average Perpetual","FIFO Periodic","LIFO Periodic";
            DataClassification = CustomerContent;
        }
        field(40; BRKFLD1; Integer)
        {
            Caption = 'BRKFLD1';
            DataClassification = CustomerContent;
        }
        field(41; PO_Line_Status_Orig; Option)
        {
            Caption = 'PO_Line_Status_Orig';
            OptionMembers = ,"New","Released","Change Order","Received","Closed","Canceled";
            DataClassification = CustomerContent;
        }
        field(42; QTY_Canceled_Orig; Decimal)
        {
            Caption = 'QTY_Canceled_Orig';
            DataClassification = CustomerContent;
        }
        field(43; OPOSTSUB; Decimal)
        {
            Caption = 'OPOSTSUB';
            DataClassification = CustomerContent;
        }
        field(44; JOBNUMBR; Text[18])
        {
            Caption = 'JOBNUMBR';
            DataClassification = CustomerContent;
        }
        field(45; COSTCODE; Text[28])
        {
            Caption = 'COSTCODE';
            DataClassification = CustomerContent;
        }
        field(46; COSTTYPE; Integer)
        {
            Caption = 'COSTTYPE';
            DataClassification = CustomerContent;
        }
        field(47; CURNCYID; Text[16])
        {
            Caption = 'CURNCYID';
            DataClassification = CustomerContent;
        }
        field(48; CURRNIDX; Integer)
        {
            Caption = 'CURRNIDX';
            DataClassification = CustomerContent;
        }
        field(49; XCHGRATE; Decimal)
        {
            Caption = 'XCHGRATE';
            DataClassification = CustomerContent;
        }
        field(50; RATECALC; Integer)
        {
            Caption = 'RATECALC';
            DataClassification = CustomerContent;
        }
        field(51; DENXRATE; Decimal)
        {
            Caption = 'DENXRATE';
            DataClassification = CustomerContent;
        }
        field(52; ORUNTCST; Decimal)
        {
            Caption = 'ORUNTCST';
            DataClassification = CustomerContent;
        }
        field(53; OREXTCST; Decimal)
        {
            Caption = 'OREXTCST';
            DataClassification = CustomerContent;
        }
        field(54; LINEORIGIN; Option)
        {
            Caption = 'LINEORIGIN';
            OptionMembers = ,"Manual","e.Req.","SOP","MRP","SMS-CL","SMS-RT","SMS-DP","MOP","PO-Gen","POREQ";
            DataClassification = CustomerContent;
        }
        field(55; FREEONBOARD; Option)
        {
            Caption = 'FREEONBOARD';
            OptionMembers = ,"None","Origin","Destination";
            DataClassification = CustomerContent;
        }
        field(56; ODECPLCU; Option)
        {
            Caption = 'ODECPLCU';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(57; Capital_Item; Boolean)
        {
            Caption = 'Capital_Item';
            DataClassification = CustomerContent;
        }
        field(58; Product_Indicator; Integer)
        {
            Caption = 'Product_Indicator';
            DataClassification = CustomerContent;
        }
        field(59; Source_Document_Number; Text[12])
        {
            Caption = 'Source_Document_Number';
            DataClassification = CustomerContent;
        }
        field(60; Source_Document_Line_Num; Integer)
        {
            Caption = 'Source_Document_Line_Num';
            DataClassification = CustomerContent;
        }
        field(61; RELEASEBYDATE; Date)
        {
            Caption = 'RELEASEBYDATE';
            DataClassification = CustomerContent;
        }
        field(62; Released_Date; Date)
        {
            Caption = 'Released_Date';
            DataClassification = CustomerContent;
        }
        field(63; Change_Order_Flag; Integer)
        {
            Caption = 'Change_Order_Flag';
            DataClassification = CustomerContent;
        }
        field(64; Purchase_IV_Item_Taxable; Option)
        {
            Caption = 'Purchase_IV_Item_Taxable';
            OptionMembers = ,"Tabable","Nontaxable","Base on vendor";
            DataClassification = CustomerContent;
        }
        field(65; Purchase_Item_Tax_Schedu; Text[16])
        {
            Caption = 'Purchase_Item_Tax_Schedu';
            DataClassification = CustomerContent;
        }
        field(66; Purchase_Site_Tax_Schedu; Text[16])
        {
            Caption = 'Purchase_Site_Tax_Schedu';
            DataClassification = CustomerContent;
        }
        field(67; PURCHSITETXSCHSRC; Integer)
        {
            Caption = 'PURCHSITETXSCHSRC';
            DataClassification = CustomerContent;
        }
        field(68; BSIVCTTL; Boolean)
        {
            Caption = 'BSIVCTTL';
            DataClassification = CustomerContent;
        }
        field(69; TAXAMNT; Decimal)
        {
            Caption = 'TAXAMNT';
            DataClassification = CustomerContent;
        }
        field(70; ORTAXAMT; Decimal)
        {
            Caption = 'ORTAXAMT';
            DataClassification = CustomerContent;
        }
        field(71; BCKTXAMT; Decimal)
        {
            Caption = 'BCKTXAMT';
            DataClassification = CustomerContent;
        }
        field(72; OBTAXAMT; Decimal)
        {
            Caption = 'OBTAXAMT';
            DataClassification = CustomerContent;
        }
        field(73; Landed_Cost_Group_ID; Text[16])
        {
            Caption = 'Landed_Cost_Group_ID';
            DataClassification = CustomerContent;
        }
        field(74; PLNNDSPPLID; Integer)
        {
            Caption = 'PLNNDSPPLID';
            DataClassification = CustomerContent;
        }
        field(75; SHIPMTHD; Text[16])
        {
            Caption = 'SHIPMTHD';
            DataClassification = CustomerContent;
        }
        field(76; BackoutTradeDiscTax; Decimal)
        {
            Caption = 'BackoutTradeDiscTax';
            DataClassification = CustomerContent;
        }
        field(77; OrigBackoutTradeDiscTax; Decimal)
        {
            Caption = 'OrigBackoutTradeDiscTax';
            DataClassification = CustomerContent;
        }
        field(78; LineNumber; Integer)
        {
            Caption = 'LineNumber';
            DataClassification = CustomerContent;
        }
        field(79; ORIGPRMDATE; Date)
        {
            Caption = 'ORIGPRMDATE';
            DataClassification = CustomerContent;
        }
        field(80; FSTRCPTDT; Date)
        {
            Caption = 'FSTRCPTDT';
            DataClassification = CustomerContent;
        }
        field(81; LSTRCPTDT; Date)
        {
            Caption = 'LSTRCPTDT';
            DataClassification = CustomerContent;
        }
        field(82; RELEASE; Integer)
        {
            Caption = 'RELEASE';
            DataClassification = CustomerContent;
        }
        field(83; ADRSCODE; Text[16])
        {
            Caption = 'ADRSCODE';
            DataClassification = CustomerContent;
        }
        field(84; CMPNYNAM; Text[66])
        {
            Caption = 'CMPNYNAM';
            DataClassification = CustomerContent;
        }
        field(85; CONTACT; Text[62])
        {
            Caption = 'CONTACT';
            DataClassification = CustomerContent;
        }
        field(86; ADDRESS1; Text[62])
        {
            Caption = 'ADDRESS1';
            DataClassification = CustomerContent;
        }
        field(87; ADDRESS2; Text[62])
        {
            Caption = 'ADDRESS2';
            DataClassification = CustomerContent;
        }
        field(88; ADDRESS3; Text[62])
        {
            Caption = 'ADDRESS3';
            DataClassification = CustomerContent;
        }
        field(89; CITY; Text[36])
        {
            Caption = 'CITY';
            DataClassification = CustomerContent;
        }
        field(90; STATE; Text[30])
        {
            Caption = 'STATE';
            DataClassification = CustomerContent;
        }
        field(91; ZIPCODE; Text[12])
        {
            Caption = 'ZIPCODE';
            DataClassification = CustomerContent;
        }
        field(92; CCode; Text[8])
        {
            Caption = 'CCode';
            DataClassification = CustomerContent;
        }
        field(93; COUNTRY; Text[62])
        {
            Caption = 'COUNTRY';
            DataClassification = CustomerContent;
        }
        field(94; PHONE1; Text[22])
        {
            Caption = 'PHONE1';
            DataClassification = CustomerContent;
        }
        field(95; PHONE2; Text[22])
        {
            Caption = 'PHONE2';
            DataClassification = CustomerContent;
        }
        field(96; PHONE3; Text[22])
        {
            Caption = 'PHONE3';
            DataClassification = CustomerContent;
        }
        field(97; FAX; Text[22])
        {
            Caption = 'FAX';
            DataClassification = CustomerContent;
        }
        field(98; ADDRSOURCE; Integer)
        {
            Caption = 'ADDRSOURCE';
            DataClassification = CustomerContent;
        }
        field(99; Flags; Integer)
        {
            Caption = 'Flags';
            DataClassification = CustomerContent;
        }
        field(100; ProjNum; Text[16])
        {
            Caption = 'ProjNum';
            DataClassification = CustomerContent;
        }
        field(101; CostCatID; Text[16])
        {
            Caption = 'CostCatID';
            DataClassification = CustomerContent;
        }
        field(102; Print_Phone_NumberGB; Integer)
        {
            Caption = 'Print_Phone_NumberGB';
            DataClassification = CustomerContent;
        }
        field(103; QTYCommittedInBaseOrig; Decimal)
        {
            Caption = 'QTYCommittedInBaseOrig';
            DataClassification = CustomerContent;
        }
        field(104; DEX_ROW_TS; DateTime)
        {
            Caption = 'DEX_ROW_TS';
            DataClassification = CustomerContent;
        }
        field(105; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PONUMBER, ORD, BRKFLD1)
        {
            Clustered = true;
        }
    }

    var
        PostingGroupTxt: Label 'GP', Locked = true;

    procedure MoveStagingData(PO_Number: Text[18])
    var
        PurchaseLine: Record "Purchase Line";
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseLineType: Enum "Purchase Line Type";
        LineNo: Integer;
        QtyShipped: Decimal;
    begin
        LineNo := 10000;
        SetRange(PONUMBER, PO_Number);
        if FindSet() then
            repeat
                PurchaseLine.Init();
                PurchaseLine."Document No." := PO_Number;
                PurchaseLine."Document Type" := PurchaseDocumentType::Order;
                PurchaseLine."Line No." := LineNo;
                PurchaseLine."Buy-from Vendor No." := VENDORID;
                PurchaseLine.Type := PurchaseLineType::Item;
                if NONINVEN = 1 then
                    CreateNonInventoryItem(CopyStr(ITEMNMBR, 1, 20), CopyStr(ITEMDESC, 1, 100), UNITCOST, UOFM);

                PurchaseLine.Validate("Gen. Bus. Posting Group", PostingGroupTxt);
                PurchaseLine.Validate("Gen. Prod. Posting Group", PostingGroupTxt);
                PurchaseLine."Unit of Measure" := UOFM;
                PurchaseLine."Unit of Measure Code" := UOFM;
                PurchaseLine.Validate("No.", CopyStr(ITEMNMBR, 1, 20));
                PurchaseLine."Location Code" := CopyStr(LOCNCODE, 1, 10);
                PurchaseLine."Posting Group" := PostingGroupTxt;
                PurchaseLine.Validate("Expected Receipt Date", PRMDATE);
                PurchaseLine.Description := CopyStr(ITEMDESC, 1, 100);

                QtyShipped := GPPOPReceiptApply.GetSumQtyShipped(PO_Number, ORD);
                PurchaseLine.Validate("Quantity (Base)", QTYORDER - QTYCANCE);
                PurchaseLine."Quantity Received" := QtyShipped;
                PurchaseLine."Qty. Received (Base)" := QtyShipped;
                PurchaseLine."Quantity Invoiced" := GPPOPReceiptApply.GetSumQtyInvoiced(PO_Number, ORD);
                PurchaseLine."Outstanding Quantity" := PurchaseLine."Quantity (Base)" - QtyShipped;
                PurchaseLine.Validate("Direct Unit Cost", UNITCOST);
                PurchaseLine.Validate(Amount, EXTDCOST);
                PurchaseLine.Validate("Outstanding Amount", PurchaseLine."Outstanding Quantity" * UNITCOST);
                PurchaseLine."Qty. Rcd. Not Invoiced" := QtyShipped - PurchaseLine."Quantity Invoiced";
                PurchaseLine.Validate("Amt. Rcd. Not Invoiced", PurchaseLine."Qty. Rcd. Not Invoiced" * UNITCOST);
                PurchaseLine."Outstanding Amount (LCY)" := PurchaseLine."Outstanding Amount";
                PurchaseLine."Amt. Rcd. Not Invoiced (LCY)" := PurchaseLine."Amt. Rcd. Not Invoiced";
                PurchaseLine."Unit Cost" := UNITCOST;
                PurchaseLine.Insert(true);

                if QtyShipped > (QTYORDER - QTYCANCE) then
                    ProcessOverReceipt(PurchaseLine, QtyShipped - (QTYORDER - QTYCANCE));

                PurchaseLine.Validate("Qty. to Receive (Base)", PurchaseLine."Outstanding Quantity");
                PurchaseLine.Validate("Outstanding Qty. (Base)", PurchaseLine."Outstanding Quantity");
                PurchaseLine.Validate("Qty. to Invoice (Base)", PurchaseLine."Quantity (Base)" - PurchaseLine."Quantity Invoiced");

                if PurchaseLine.Amount > 0 then
                    PurchaseLine.Validate("Line Amount", PurchaseLine.Amount)
                else
                    PurchaseLine."Line Amount" := PurchaseLine.Amount;

                PurchaseLine.Modify(true);
                LineNo := LineNo + 10000;
            until Next() = 0;
    end;

    local procedure CreateNonInventoryItem(ItemNo: Code[20]; ItemDescription: Text[100]; UnitCost: Decimal; UnitOfMeasure: Text[10])
    var
        NewItem: Record Item;
        ItemType: Enum "Item Type";
    begin
        NewItem.SetRange("No.", ItemNo);
        if not NewItem.IsEmpty() then
            exit;

        NewItem.Init();
        NewItem.Validate("No.", ItemNo);
        NewItem.Description := ItemDescription;
        NewItem.Validate(Type, ItemType::"Non-Inventory");
        NewItem.Validate("Unit Cost", UnitCost);
        NewItem.Validate("Gen. Prod. Posting Group", PostingGroupTxt);
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

        if not OverReceiptCode.Get('GP') then begin
            OverReceiptCode.Validate(Code, 'GP');
            OverReceiptCode.Validate(Description, 'Migrated from GP');
            OverReceiptCode.Validate("Over-Receipt Tolerance %", OveragePercentage * 100);
            OverReceiptCode.Insert(true);
        end else
            if OverReceiptCode."Over-Receipt Tolerance %" < OveragePercentage * 100 then begin
                OverReceiptCode.Validate("Over-Receipt Tolerance %", OveragePercentage * 100);
                OverReceiptCode.Modify();
            end;

        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseLine."Document No.") then begin
            PurchaseHeader.Status := PurchaseDocumentStatus::Released;
            PurchaseHeader.Modify();
            PurchaseLine.Validate("Over-Receipt Code", 'GP');
            PurchaseLine.Validate("Over-Receipt Quantity", OverReceiptQty);
            PurchaseLine.Modify();
            PurchaseHeader.Status := PurchaseDocumentStatus::Open;
            PurchaseHeader.Modify();
        end;
    end;
}