table 4035 "GPIVBinQtyTransferHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; DOCTYPE; Option)
        {
            Caption = 'Document Type';
            OptionMembers = ,"Adjustment","Variance","Transfer","Receipt","Return","Sale","Assembly","Standard Cost Adjustment","Cost Adjustment via PO Edit Status","Cost Adjustment via PO Return","Cost Adjustment via PO Invoice Match","Cost Adjustment via PO Landed Cost Match","Cost Adjustment via PO Tax";
            DataClassification = CustomerContent;
        }
        field(2; Bin_XFer_Doc_Number; text[22])
        {
            Caption = 'Bin Transfer Document Number';
            DataClassification = CustomerContent;
        }
        field(3; Bin_XFer_Date; Date)
        {
            Caption = 'Bin Transfer Date';
            DataClassification = CustomerContent;
        }
        field(4; SEQNUMBR; Integer)
        {
            Caption = 'Sequence Number';
            DataClassification = CustomerContent;
        }
        field(5; ITEMNMBR; text[32])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(6; LOCNCODE; text[12])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(7; QTYTYPE; Option)
        {
            Caption = 'QTY Type';
            OptionMembers = ,"On Hand","Returned","In Use","In Service","Damaged";
            DataClassification = CustomerContent;
        }
        field(8; FROMBIN; text[16])
        {
            Caption = 'From Bin';
            DataClassification = CustomerContent;
        }
        field(9; TOBIN; text[16])
        {
            Caption = 'To Bin';
            DataClassification = CustomerContent;
        }
        field(10; SERLTNUM; text[22])
        {
            Caption = 'Serial/Lot Number';
            DataClassification = CustomerContent;
        }
        field(11; SERLTQTY; Decimal)
        {
            Caption = 'Serial/Lot QTY';
            DataClassification = CustomerContent;
        }
        field(12; DATERECD; Date)
        {
            Caption = 'Date Received';
            DataClassification = CustomerContent;
        }
        field(13; DTSEQNUM; Decimal)
        {
            Caption = 'Date SEQ Number';
            DataClassification = CustomerContent;
        }
        field(14; OVRSERLT; Integer)
        {
            Caption = 'Override Serial/Lot';
            DataClassification = CustomerContent;
        }
        field(15; Reason_Code; text[16])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
        }
        field(16; USERID; text[16])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(17; NOTEINDX; Decimal)
        {
            Caption = 'Note Index';
            DataClassification = CustomerContent;
        }
        field(18; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; DOCTYPE, Bin_XFer_Doc_Number, Bin_XFer_Date, SEQNUMBR)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
