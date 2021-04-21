table 4050 "GPIVTrxBinQtyHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; DOCNUMBR; text[22])
        {
            Caption = 'Document Number';
            DataClassification = CustomerContent;
        }
        field(2; DOCTYPE; Option)
        {
            Caption = 'Document Type';
            OptionMembers = ,"Adjustment","Variance","Transfer","Receipt","Return","Sale","Assembly","Standard Cost Adjustment","Cost Adjustment via PO Edit Status","Cost Adjustment via PO Return","Cost Adjustment via PO Invoice Match","Cost Adjustment via PO Landed Cost Match","Cost Adjustment via PO Tax";
            DataClassification = CustomerContent;
        }
        field(3; LNSEQNBR; Decimal)
        {
            Caption = 'Line SEQ Number';
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
        field(7; BIN; text[16])
        {
            Caption = 'Bin';
            DataClassification = CustomerContent;
        }
        field(8; TOBIN; text[16])
        {
            Caption = 'To Bin';
            DataClassification = CustomerContent;
        }
        field(9; QTYTYPE; Option)
        {
            Caption = 'QTY Type';
            OptionMembers = ,"On Hand","Returned","In Use","In Service","Damaged";
            DataClassification = CustomerContent;
        }
        field(10; QTYSLCTD; Decimal)
        {
            Caption = 'QTY Selected';
            DataClassification = CustomerContent;
        }
        field(11; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; DOCTYPE, DOCNUMBR, LNSEQNBR, SEQNUMBR)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
