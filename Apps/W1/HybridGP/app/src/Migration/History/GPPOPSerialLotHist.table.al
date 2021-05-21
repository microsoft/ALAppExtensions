table 4063 "GPPOPSerialLotHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; POPRCTNM; text[18])
        {
            Caption = 'POP Receipt Number';
            DataClassification = CustomerContent;
        }
        field(2; RCPTLNNM; Integer)
        {
            Caption = 'Receipt Line Number';
            DataClassification = CustomerContent;
        }
        field(3; SLTSQNUM; Integer)
        {
            Caption = 'Serial/Lot SEQ Number';
            DataClassification = CustomerContent;
        }
        field(4; SERLTNUM; text[22])
        {
            Caption = 'Serial/Lot Number';
            DataClassification = CustomerContent;
        }
        field(5; SERLTQTY; Decimal)
        {
            Caption = 'Serial/Lot QTY';
            DataClassification = CustomerContent;
        }
        field(6; DATERECD; Date)
        {
            Caption = 'Date Received';
            DataClassification = CustomerContent;
        }
        field(7; DTSEQNUM; Decimal)
        {
            Caption = 'Date SEQ Number';
            DataClassification = CustomerContent;
        }
        field(8; UNITCOST; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(9; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(10; ITEMNMBR; text[32])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(11; QTYTYPE; Option)
        {
            Caption = 'QTY Type';
            OptionMembers = ,"On Hand","Returned","In Use","In Service","Damaged";
            DataClassification = CustomerContent;
        }
        field(12; BIN; text[16])
        {
            Caption = 'Bin';
            DataClassification = CustomerContent;
        }
        field(13; MFGDATE; Date)
        {
            Caption = 'Manufacture Date';
            DataClassification = CustomerContent;
        }
        field(14; EXPNDATE; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(15; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; POPRCTNM, RCPTLNNM, QTYTYPE, SLTSQNUM)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
