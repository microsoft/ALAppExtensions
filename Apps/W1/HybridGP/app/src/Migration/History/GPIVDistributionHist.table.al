table 4036 "GPIVDistributionHist"
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
        field(3; ITEMNMBR; text[32])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(4; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(5; ACTINDX; Integer)
        {
            Caption = 'Account Index';
            DataClassification = CustomerContent;
        }
        field(6; DISTTYPE; Option)
        {
            Caption = 'Distribution Type';
            OptionMembers = ,"SALES","RECV","CASH","TAKEN","AVAIL","TRADE","FREIGHT","MISC","TAXES","MARK","COMMEXP","COMMPAY","OTHER","COGS","INV","RETURNS","IN USE","IN SERVICE","DAMAGED","UNIT","DEPOSITS","ROUND","REBATE","RZGAIN","RZLOSS";
            DataClassification = CustomerContent;
        }
        field(7; POSTEDDT; Date)
        {
            Caption = 'Posted Date';
            DataClassification = CustomerContent;
        }
        field(8; DEBITAMT; Decimal)
        {
            Caption = 'Debit Amount';
            DataClassification = CustomerContent;
        }
        field(9; CRDTAMNT; Decimal)
        {
            Caption = 'Credit Amount';
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
        key(PK; TRXSORCE, ACTINDX, DEX_ROW_ID)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
