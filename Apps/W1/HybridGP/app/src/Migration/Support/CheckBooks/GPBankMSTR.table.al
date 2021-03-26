table 40100 "GP Bank MSTR"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; BANKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; BANKNAME; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(3; ADDRESS1; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(4; ADDRESS2; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(5; ADDRESS3; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(6; CITY; Text[35])
        {
            DataClassification = CustomerContent;
        }
        field(7; STATE; Text[29])
        {
            DataClassification = CustomerContent;
        }
        field(8; ZIPCODE; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(9; COUNTRY; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(10; PHNUMBR1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(11; PHNUMBR2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(12; PHONE3; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(13; FAXNUMBR; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(14; TRNSTNBR; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(15; BNKBRNCH; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(16; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(17; DDTRANUM; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(18; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; BANKID)
        {
            Clustered = true;
        }
    }

}