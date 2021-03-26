table 4052 "GPIVTrxHist"
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
        field(4; DOCDATE; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(5; BCHSOURC; text[16])
        {
            Caption = 'Batch Source';
            DataClassification = CustomerContent;
        }
        field(6; BACHNUMB; text[16])
        {
            Caption = 'Batch Number';
            DataClassification = CustomerContent;
        }
        field(7; NOTEINDX; Decimal)
        {
            Caption = 'Note Index';
            DataClassification = CustomerContent;
        }
        field(8; GLPOSTDT; Date)
        {
            Caption = 'GL Posting Date';
            DataClassification = CustomerContent;
        }
        field(9; SRCRFRNCNMBR; text[32])
        {
            Caption = 'Source Reference Number';
            DataClassification = CustomerContent;
        }
        field(10; SOURCEINDICATOR; Option)
        {
            Caption = 'Source Indicator';
            OptionMembers = ,"(none)","Issue","Reverse Issue","Finished Good Post","Reverse Finished Good Post","Stock Count","Field Service Call Entry","Field Service RMA Entry","Field Service RTV Entry","Field Service Work Order Entry","Project Accounting","In-Transit Transfer";
            DataClassification = CustomerContent;
        }
        field(11; DEX_ROW_TS; DateTime)
        {
            Caption = 'DEX_ROW_TS';
            DataClassification = CustomerContent;
        }
        field(12; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; TRXSORCE, IVDOCTYP, DOCNUMBR)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
