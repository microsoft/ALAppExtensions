table 40129 "GP PM20000"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; VCHRNMBR; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(2; VENDORID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(3; DOCTYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; DOCDATE; Date)
        {
            DataClassification = CustomerContent;
        }
        field(5; DOCNUMBR; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(6; DOCAMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(7; CURTRXAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; DISTKNAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; BACHNUMB; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(12; TRXSORCE; Text[13])
        {
            DataClassification = CustomerContent;
        }
        field(13; BCHSOURC; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(15; DUEDATE; Date)
        {
            DataClassification = CustomerContent;
        }
        field(20; TRXDSCRN; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(16; PORDNMBR; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(17; TEN99AMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(18; WROFAMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(25; VOIDED; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(28; DINVPDOF; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(33; POSTEDDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(34; PTDUSRID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(40; TRDISAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(41; MSCCHAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(42; FRTAMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(43; TAXAMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(44; TTLPYMTS; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(45; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(46; PYMTRMID; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(47; SHIPMTHD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(73; TEN99TYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(74; TEN99BOXNUMBER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(75; PONUMBER; Text[17])
        {
            DataClassification = CustomerContent;
        }
        field(80; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; DOCTYPE, VCHRNMBR)
        {
            Clustered = true;
        }

        key(Key2; DOCTYPE, CURTRXAM, VOIDED)
        {
        }
        key(Key3; DEX_ROW_ID)
        {
        }
    }
}

