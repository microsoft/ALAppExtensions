namespace Microsoft.DataMigration.GP;

table 41001 "GP GL20000"
{
    Description = 'Open Year Posted Transactions';
    DataClassification = CustomerContent;

    fields
    {
        field(1; OPENYEAR; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; JRNENTRY; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; SOURCDOC; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(5; REFRENCE; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(6; DSCRIPTN; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(7; TRXDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(8; TRXSORCE; Text[13])
        {
            DataClassification = CustomerContent;
        }
        field(9; ACTINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(13; USWHPSTD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(17; SERIES; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(20; ORMSTRID; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(21; ORMSTRNM; Text[65])
        {
            DataClassification = CustomerContent;
        }
        field(22; ORDOCNUM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(24; ORTRXSRC; Text[13])
        {
            DataClassification = CustomerContent;
        }
        field(27; SEQNUMBR; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(30; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(43; DEBITAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(44; CRDTAMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(45; ORDBTAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(46; ORCRDAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(66; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(100; User_Defined_Text01; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(101; User_Defined_Text02; Text[31])
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; DEX_ROW_ID)
        {
            Clustered = true;
        }
        key(K2; SOURCDOC)
        {

        }
    }
}