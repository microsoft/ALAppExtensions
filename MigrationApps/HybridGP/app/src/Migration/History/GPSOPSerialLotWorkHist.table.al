table 4074 "GPSOPSerialLotWorkHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; SOPTYPE; Option)
        {
            Caption = 'SOP Type';
            OptionMembers = ,"Quote","Order","Invoice","Return","Back Order","FulFillment Order";
            DataClassification = CustomerContent;
        }
        field(2; SOPNUMBE; text[22])
        {
            Caption = 'SOP Number';
            DataClassification = CustomerContent;
        }
        field(3; LNITMSEQ; Integer)
        {
            Caption = 'Line Item Sequence';
            DataClassification = CustomerContent;
        }
        field(4; CMPNTSEQ; Integer)
        {
            Caption = 'Component Sequence';
            DataClassification = CustomerContent;
        }
        field(5; QTYTYPE; Option)
        {
            Caption = 'QTY Type';
            OptionMembers = ,"On Hand","Returned","In Use","In Service","Damaged";
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
        field(8; SLTSQNUM; Integer)
        {
            Caption = 'Serial/Lot SEQ Number';
            DataClassification = CustomerContent;
        }
        field(9; DATERECD; Date)
        {
            Caption = 'Date Received';
            DataClassification = CustomerContent;
        }
        field(10; DTSEQNUM; Decimal)
        {
            Caption = 'Date SEQ Number';
            DataClassification = CustomerContent;
        }
        field(11; UNITCOST; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(12; ITEMNMBR; text[32])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(13; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(14; POSTED; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(15; OVRSERLT; Integer)
        {
            Caption = 'Override Serial/Lot';
            DataClassification = CustomerContent;
        }
        field(16; BIN; text[16])
        {
            Caption = 'Bin';
            DataClassification = CustomerContent;
        }
        field(17; MFGDATE; Date)
        {
            Caption = 'Manufacture Date';
            DataClassification = CustomerContent;
        }
        field(18; EXPNDATE; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(19; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPTYPE, SOPNUMBE, LNITMSEQ, CMPNTSEQ, QTYTYPE, SLTSQNUM)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
