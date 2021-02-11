table 4051 "GPIVTrxDetailHist"
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
        field(4; DTLSEQNM; Integer)
        {
            Caption = 'Detail SEQ Number';
            DataClassification = CustomerContent;
        }
        field(5; QTYTYPE; Option)
        {
            Caption = 'QTY Type';
            OptionMembers = ,"On Hand","Returned","In Use","In Service","Damaged";
            DataClassification = CustomerContent;
        }
        field(6; RCPTNMBR; text[22])
        {
            Caption = 'Receipt Number';
            DataClassification = CustomerContent;
        }
        field(7; RCPTQTY; Decimal)
        {
            Caption = 'Receipt QTY';
            DataClassification = CustomerContent;
        }
        field(8; RCPTEXCT; Decimal)
        {
            Caption = 'Receipt Extended Cost';
            DataClassification = CustomerContent;
        }
        field(9; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; DOCTYPE, DOCNUMBR, LNSEQNBR, DTLSEQNM)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
