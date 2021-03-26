table 4039 "GPIVTrxAmountsHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(2; DOCTYPE; Option)
        {
            Caption = 'Document Type';
            OptionMembers = ,"Adjustment","Variance","Transfer","Receipt","Return","Sale","Assembly","Standard Cost Adjustment","Cost Adjustment via PO Edit Status","Cost Adjustment via PO Return","Cost Adjustment via PO Invoice Match","Cost Adjustment via PO Landed Cost Match","Cost Adjustment via PO Tax";
            DataClassification = CustomerContent;
        }
        field(3; DOCNUMBR; text[22])
        {
            Caption = 'Document Number';
            DataClassification = CustomerContent;
        }
        field(4; DOCDATE; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(5; HSTMODUL; text[4])
        {
            Caption = 'History Module';
            DataClassification = CustomerContent;
        }
        field(6; CUSTNMBR; text[16])
        {
            Caption = 'Customer Number';
            DataClassification = CustomerContent;
        }
        field(7; ITEMNMBR; text[32])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(8; LNSEQNBR; Decimal)
        {
            Caption = 'Line SEQ Number';
            DataClassification = CustomerContent;
        }
        field(9; UOFM; text[10])
        {
            Caption = 'U Of M';
            DataClassification = CustomerContent;
        }
        field(10; TRXQTY; Decimal)
        {
            Caption = 'TRX QTY';
            DataClassification = CustomerContent;
        }
        field(11; UNITCOST; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(12; EXTDCOST; Decimal)
        {
            Caption = 'Extended Cost';
            DataClassification = CustomerContent;
        }
        field(13; TRXLOCTN; text[12])
        {
            Caption = 'TRX Location';
            DataClassification = CustomerContent;
        }
        field(14; TRNSTLOC; text[12])
        {
            Caption = 'Transfer To Location';
            DataClassification = CustomerContent;
        }
        field(15; TRFQTYTY; Option)
        {
            Caption = 'Transfer From QTY Type';
            OptionMembers = ,"On Hand","Returned","In Use","In Service","Damaged";
            DataClassification = CustomerContent;
        }
        field(16; TRTQTYTY; Option)
        {
            Caption = 'Transfer To QTY Type';
            OptionMembers = ,"On Hand","Returned","In Use","In Service","Damaged";
            DataClassification = CustomerContent;
        }
        field(17; IVIVINDX; Integer)
        {
            Caption = 'IV IV Index';
            DataClassification = CustomerContent;
        }
        field(18; IVIVOFIX; Integer)
        {
            Caption = 'IV IV Offset Index';
            DataClassification = CustomerContent;
        }
        field(19; DECPLCUR; Option)
        {
            Caption = 'Decimal Places Currency';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(20; DECPLQTY; Option)
        {
            Caption = 'Decimal Places QTYS';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(21; QTYBSUOM; Decimal)
        {
            Caption = 'QTY In Base U Of M';
            DataClassification = CustomerContent;
        }
        field(22; Reason_Code; text[16])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
        }
        field(23; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; DOCTYPE, DOCNUMBR, LNSEQNBR)
        {
            Clustered = false;
        }
        key(Key2; DOCTYPE, ITEMNMBR, DOCDATE, DOCNUMBR)
        {
            Clustered = false;
        }

    }

    fieldgroups
    {
    }

}
