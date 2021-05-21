table 4038 "GPIVSerialLotNumberHist"
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
        field(2; IVDOCTYP; Option)
        {
            Caption = 'IV Document Type';
            OptionMembers = ,"Adjustment","Variance","Transfer","Receipt","Return","Sale","Bill of Materials","Standard Cost Adjustment","Cost Adjustment via PO Edit Status","Cost Adjustment via PO Return","Cost Adjustment via PO Invoice Match","Cost Adjustment via PO Landed Cost Match","Cost Adjustment via PO Tax";
            DataClassification = CustomerContent;
        }
        field(3; DOCNUMBR; text[22])
        {
            Caption = 'Document Number';
            DataClassification = CustomerContent;
        }
        field(4; LNSEQNBR; Decimal)
        {
            Caption = 'Line SEQ Number';
            DataClassification = CustomerContent;
        }
        field(5; SLTSQNUM; Integer)
        {
            Caption = 'Serial/Lot SEQ Number';
            DataClassification = CustomerContent;
        }
        field(6; SERLTNUM; text[22])
        {
            Caption = 'Serial/Lot Number';
            DataClassification = CustomerContent;
        }
        field(7; SERLTQTY; Decimal)
        {
            Caption = 'Serial/Lot QTY';
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
        field(10; ITEMNMBR; text[32])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(11; MFGDATE; Date)
        {
            Caption = 'Manufacture Date';
            DataClassification = CustomerContent;
        }
        field(12; EXPNDATE; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(13; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; TRXSORCE, IVDOCTYP, DOCNUMBR, LNSEQNBR, SLTSQNUM)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
