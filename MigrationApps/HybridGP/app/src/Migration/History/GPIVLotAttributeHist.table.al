table 4081 "GPIVLotAttributeHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; IVDOCTYP; Option)
        {
            Caption = 'IV Document Type';
            OptionMembers = ,"Adjustment","Variance","Transfer","Receipt","Return","Sale","Bill of Materials","Standard Cost Adjustment","Cost Adjustment via PO Edit Status","Cost Adjustment via PO Return","Cost Adjustment via PO Invoice Match","Cost Adjustment via PO Landed Cost Match","Cost Adjustment via PO Tax";
            DataClassification = CustomerContent;
        }
        field(2; DOCNUMBR; text[22])
        {
            Caption = 'Document Number';
            DataClassification = CustomerContent;
        }
        field(3; LNSEQNBR; Decimal)
        {
            Caption = 'Line SEQ Number';
            DataClassification = CustomerContent;
        }
        field(4; SLTSQNUM; Integer)
        {
            Caption = 'Serial/Lot SEQ Number';
            DataClassification = CustomerContent;
        }
        field(5; LOTATRB1; text[12])
        {
            Caption = 'Lot Attribute 1';
            DataClassification = CustomerContent;
        }
        field(6; LOTATRB2; text[12])
        {
            Caption = 'Lot Attribute 2';
            DataClassification = CustomerContent;
        }
        field(7; LOTATRB3; text[12])
        {
            Caption = 'Lot Attribute 3';
            DataClassification = CustomerContent;
        }
        field(8; LOTATRB4; Date)
        {
            Caption = 'Lot Attribute 4';
            DataClassification = CustomerContent;
        }
        field(9; LOTATRB5; Date)
        {
            Caption = 'Lot Attribute 5';
            DataClassification = CustomerContent;
        }
        field(10; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; IVDOCTYP, DOCNUMBR, LNSEQNBR, SLTSQNUM)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
