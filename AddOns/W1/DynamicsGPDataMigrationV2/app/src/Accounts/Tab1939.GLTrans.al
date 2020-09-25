table 1939 "MigrationGP GLTrans"
{
    ReplicateData = false;

    fields
    {
        field(1; Id; Text[40])
        {
            Caption = 'Id Number';
            DataClassification = CustomerContent;
        }
        field(2; ACTINDX; Integer)
        {
            Caption = 'Account Index';
            DataClassification = CustomerContent;
        }
        field(3; GLDocNo; Text[30])
        {
            Caption = 'General Ledger Document Number';
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
        field(9; AccountNumber; Code[20])
        {
            Caption = 'Account Number';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
        key(TrxKey; YEAR1, PERIODID, AccountNumber)
        {

        }
    }

    fieldgroups
    {
    }
}