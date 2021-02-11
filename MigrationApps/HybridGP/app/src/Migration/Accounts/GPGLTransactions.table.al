table 4091 "GP GLTransactions"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id Number';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(2; ACTINDX; Integer)
        {
            Caption = 'Account Index';
            DataClassification = CustomerContent;
        }
        field(4; YEAR1; Integer)
        {
            Caption = 'Year';
            DataClassification = CustomerContent;
        }
        field(5; PERIODID; Integer)
        {
            Caption = 'Fiscal Period';
            DataClassification = CustomerContent;
        }
        field(6; DEBITAMT; Decimal)
        {
            Caption = 'Debit Amount';
            DataClassification = CustomerContent;
        }
        field(7; CRDTAMNT; Decimal)
        {
            Caption = 'Credit Amount';
            DataClassification = CustomerContent;
        }
        field(8; PERDBLNC; Decimal)
        {
            Caption = 'Period Balance';
            DataClassification = CustomerContent;
        }
        field(9; "MNACSGMT"; Integer)
        {
            Caption = 'Main account segment';
            DataClassification = SystemMetadata;
        }
        field(10; ACTNUMBR_1; Code[20])
        {
            Caption = 'Account Segment 1';
            DataClassification = CustomerContent;
        }
        field(11; ACTNUMBR_2; Code[20])
        {
            Caption = 'Account Segment 2';
            DataClassification = CustomerContent;
        }
        field(12; ACTNUMBR_3; Code[20])
        {
            Caption = 'Account Segment 3';
            DataClassification = CustomerContent;
        }
        field(13; ACTNUMBR_4; Code[20])
        {
            Caption = 'Account Segment 4';
            DataClassification = CustomerContent;
        }
        field(14; ACTNUMBR_5; Code[20])
        {
            Caption = 'Account Segment 5';
            DataClassification = CustomerContent;
        }
        field(15; ACTNUMBR_6; Code[20])
        {
            Caption = 'Account Segment 6';
            DataClassification = CustomerContent;
        }
        field(16; ACTNUMBR_7; Code[20])
        {
            Caption = 'Account Segment 7';
            DataClassification = CustomerContent;
        }
        field(17; ACTNUMBR_8; Code[20])
        {
            Caption = 'Account Segment 8';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
        key(TrxKey; YEAR1, PERIODID, ACTINDX)
        {

        }
    }

    fieldgroups
    {
    }
}