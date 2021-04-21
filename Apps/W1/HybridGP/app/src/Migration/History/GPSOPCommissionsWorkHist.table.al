table 4068 "GPSOPCommissionsWorkHist"
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
        field(3; SEQNUMBR; Integer)
        {
            Caption = 'Sequence Number';
            DataClassification = CustomerContent;
        }
        field(4; SLPRSNID; text[16])
        {
            Caption = 'Salesperson ID';
            DataClassification = CustomerContent;
        }
        field(5; SALSTERR; text[16])
        {
            Caption = 'Sales Territory';
            DataClassification = CustomerContent;
        }
        field(6; COMPRCNT; Integer)
        {
            Caption = 'Commission Percent';
            DataClassification = CustomerContent;
        }
        field(7; COMMAMNT; Decimal)
        {
            Caption = 'Commission Amount';
            DataClassification = CustomerContent;
        }
        field(8; OCOMMAMT; Decimal)
        {
            Caption = 'Originating Commission Amount';
            DataClassification = CustomerContent;
        }
        field(9; NCOMAMNT; Decimal)
        {
            Caption = 'Non-Commissioned Amount';
            DataClassification = CustomerContent;
        }
        field(10; ORNCMAMT; Decimal)
        {
            Caption = 'Originating Non-Commissioned Amount';
            DataClassification = CustomerContent;
        }
        field(11; PRCTOSAL; Integer)
        {
            Caption = 'Percent of Sale';
            DataClassification = CustomerContent;
        }
        field(12; ACTSLAMT; Decimal)
        {
            Caption = 'Actual Sale Amount';
            DataClassification = CustomerContent;
        }
        field(13; ORSLSAMT; Decimal)
        {
            Caption = 'Originating Sales Amount';
            DataClassification = CustomerContent;
        }
        field(14; CMMSLAMT; Decimal)
        {
            Caption = 'Commission Sale Amount';
            DataClassification = CustomerContent;
        }
        field(15; ORCOSAMT; Decimal)
        {
            Caption = 'Originating Commission Sales Amount';
            DataClassification = CustomerContent;
        }
        field(16; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(17; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(18; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPNUMBE, SOPTYPE, SEQNUMBR)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}


