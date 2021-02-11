table 4067 "GPSOPBinQuantityWorkHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; SOPNUMBE; text[22])
        {
            Caption = 'SOP Number';
            DataClassification = CustomerContent;
        }
        field(2; SOPTYPE; Option)
        {
            Caption = 'SOP Type';
            OptionMembers = ,"Quote","Order","Invoice","Return","Back Order","FulFillment Order";
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
        field(5; SEQNUMBR; Integer)
        {
            Caption = 'Sequence Number';
            DataClassification = CustomerContent;
        }
        field(6; ITEMNMBR; text[32])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(7; LOCNCODE; text[12])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(8; BIN; text[16])
        {
            Caption = 'Bin';
            DataClassification = CustomerContent;
        }
        field(9; QTYTYPE; Option)
        {
            Caption = 'QTY Type';
            OptionMembers = ,"On Hand","Returned","In Use","In Service","Damaged";
            DataClassification = CustomerContent;
        }
        field(10; QUANTITY; Decimal)
        {
            Caption = 'QTY';
            DataClassification = CustomerContent;
        }
        field(11; POSTED; Boolean)
        {
            Caption = 'Posted';
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
        key(PK; SOPNUMBE, SOPTYPE, LNITMSEQ, CMPNTSEQ, SEQNUMBR)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
