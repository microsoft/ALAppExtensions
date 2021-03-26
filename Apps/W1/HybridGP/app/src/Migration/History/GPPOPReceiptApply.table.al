table 4060 "GPPOPReceiptApply"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; PONUMBER; text[18])
        {
            Caption = 'PO Number';
            DataClassification = CustomerContent;
        }
        field(2; POLNENUM; Integer)
        {
            Caption = 'PO Line Number';
            DataClassification = CustomerContent;
        }
        field(3; POPRCTNM; text[18])
        {
            Caption = 'POP Receipt Number';
            DataClassification = CustomerContent;
        }
        field(4; RCPTLNNM; Integer)
        {
            Caption = 'Receipt Line Number';
            DataClassification = CustomerContent;
        }
        field(5; QTYSHPPD; Decimal)
        {
            Caption = 'Quantity Shipped';
            DataClassification = CustomerContent;
        }
        field(6; QTYINVCD; Decimal)
        {
            Caption = 'Quantity Invoiced';
            DataClassification = CustomerContent;
        }
        field(7; QTYREJ; Decimal)
        {
            Caption = 'Quantity Rejected';
            DataClassification = CustomerContent;
        }
        field(8; QTYMATCH; Decimal)
        {
            Caption = 'Quantity Matched';
            DataClassification = CustomerContent;
        }
        field(9; QTYRESERVED; Decimal)
        {
            Caption = 'Quantity Reserved';
            DataClassification = CustomerContent;
        }
        field(10; QTYINVRESERVE; Decimal)
        {
            Caption = 'Quantity Invoice Reserve';
            DataClassification = CustomerContent;
        }
        field(11; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = "Unposted","Posted","Voided";
            DataClassification = CustomerContent;
        }
        field(12; UMQTYINB; Decimal)
        {
            Caption = 'U Of M QTY In Base';
            DataClassification = CustomerContent;
        }
        field(13; OLDCUCST; Decimal)
        {
            Caption = 'Old Current Cost';
            DataClassification = CustomerContent;
        }
        field(14; JOBNUMBR; text[18])
        {
            Caption = 'Job Number';
            DataClassification = CustomerContent;
        }
        field(15; COSTCODE; text[28])
        {
            Caption = 'Cost Code';
            DataClassification = CustomerContent;
        }
        field(16; COSTTYPE; Integer)
        {
            Caption = 'Cost Code Type';
            DataClassification = CustomerContent;
        }
        field(17; ORCPTCOST; Decimal)
        {
            Caption = 'Originating Receipt Cost';
            DataClassification = CustomerContent;
        }
        field(18; OSTDCOST; Decimal)
        {
            Caption = 'Originating Standard Cost';
            DataClassification = CustomerContent;
        }
        field(19; APPYTYPE; Option)
        {
            Caption = 'Apply Type';
            OptionMembers = ,"Shipment",,"Invoice","Return","Return w/Credit","Inventory Return","Inventory Return w/Credit","In-Transit";
            DataClassification = CustomerContent;
        }
        field(20; POPTYPE; Option)
        {
            Caption = 'POP Type';
            OptionMembers = ,"Shipment","Invoice","Shipment/Invoice","Return","Return w/Credit","Inventory Return","Inventory Return w/Credit";
            DataClassification = CustomerContent;
        }
        field(21; VENDORID; text[16])
        {
            Caption = 'Vendor ID';
            DataClassification = CustomerContent;
        }
        field(22; ITEMNMBR; text[32])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(23; UOFM; text[10])
        {
            Caption = 'U Of M';
            DataClassification = CustomerContent;
        }
        field(24; TRXLOCTN; text[12])
        {
            Caption = 'TRX Location';
            DataClassification = CustomerContent;
        }
        field(25; DATERECD; Date)
        {
            Caption = 'Date Received';
            DataClassification = CustomerContent;
        }
        field(26; RCTSEQNM; Integer)
        {
            Caption = 'Receipt SEQ Number';
            DataClassification = CustomerContent;
        }
        field(27; SPRCTSEQ; Integer)
        {
            Caption = 'Split Receipt SEQ Number';
            DataClassification = CustomerContent;
        }
        field(28; PCHRPTCT; Decimal)
        {
            Caption = 'Purchase Receipt Cost';
            DataClassification = CustomerContent;
        }
        field(29; SPRCPTCT; Decimal)
        {
            Caption = 'Split Receipt Cost';
            DataClassification = CustomerContent;
        }
        field(30; OREXTCST; Decimal)
        {
            Caption = 'Originating Extended Cost';
            DataClassification = CustomerContent;
        }
        field(31; RUPPVAMT; Decimal)
        {
            Caption = 'Remaining UPPV Amount';
            DataClassification = CustomerContent;
        }
        field(32; ACPURIDX; Integer)
        {
            Caption = 'Accrued Purchases Index';
            DataClassification = CustomerContent;
        }
        field(33; INVINDX; Integer)
        {
            Caption = 'Inventory Index';
            DataClassification = CustomerContent;
        }
        field(34; UPPVIDX; Integer)
        {
            Caption = 'Unrealized Purchase Price Variance Index';
            DataClassification = CustomerContent;
        }
        field(35; NOTEINDX; Decimal)
        {
            Caption = 'Note Index';
            DataClassification = CustomerContent;
        }
        field(36; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(37; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(38; XCHGRATE; Decimal)
        {
            Caption = 'Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(39; RATECALC; Option)
        {
            Caption = 'Rate Calc Method';
            OptionMembers = "Multiply","Divide";
            DataClassification = CustomerContent;
        }
        field(40; DENXRATE; Decimal)
        {
            Caption = 'Denomination Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(41; RATETPID; text[16])
        {
            Caption = 'Rate Type ID';
            DataClassification = CustomerContent;
        }
        field(42; EXGTBLID; text[16])
        {
            Caption = 'Exchange Table ID';
            DataClassification = CustomerContent;
        }
        field(43; Capital_Item; Boolean)
        {
            Caption = 'Capital Item';
            DataClassification = CustomerContent;
        }
        field(44; Product_Indicator; Integer)
        {
            Caption = 'Product Indicator';
            DataClassification = CustomerContent;
        }
        field(45; Total_Landed_Cost_Amount; Decimal)
        {
            Caption = 'Total Landed Cost Amount';
            DataClassification = CustomerContent;
        }
        field(46; QTYTYPE; Option)
        {
            Caption = 'QTY Type';
            OptionMembers = ,"On Hand","Returned","In Use","In Service","Damaged";
            DataClassification = CustomerContent;
        }
        field(47; Posted_LC_PPV_Amount; Decimal)
        {
            Caption = 'Posted LC PPV Amount';
            DataClassification = CustomerContent;
        }
        field(48; QTYREPLACED; Decimal)
        {
            Caption = 'Quantity Replaced';
            DataClassification = CustomerContent;
        }
        field(49; QTYINVADJ; Decimal)
        {
            Caption = 'Quantity Invoice Adjustment';
            DataClassification = CustomerContent;
        }
        field(50; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; POPRCTNM, RCPTLNNM, PONUMBER, POLNENUM)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

    procedure GetSumQtyShipped(PO_Number: Text[18]; PO_LineNo: Integer): Decimal
    var
        TotalShipped: Decimal;
    begin
        TotalShipped := 0;
        SetRange(PONUMBER, PO_Number);
        SetRange(POLNENUM, PO_LineNo);
        SetFilter(Status, '%1', Status::Posted);
        if FindSet() then
            repeat
                if QTYSHPPD > 0 then
                    TotalShipped := TotalShipped + QTYSHPPD;
            until Next() = 0;

        exit(TotalShipped);
    end;

    procedure GetSumQtyInvoiced(PO_Number: Text[18]; PO_LineNo: Integer): Decimal
    var
        TotalInvoiced: Decimal;
    begin
        TotalInvoiced := 0;
        SetRange(PONUMBER, PO_Number);
        SetRange(POLNENUM, PO_LineNo);
        SetFilter(Status, '%1', Status::Posted);
        if FindSet() then
            repeat
                if QTYINVCD > 0 then
                    TotalInvoiced := TotalInvoiced + QTYINVCD;
            until Next() = 0;

        exit(TotalInvoiced);
    end;
}
