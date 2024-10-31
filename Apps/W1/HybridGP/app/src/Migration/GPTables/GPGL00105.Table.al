namespace Microsoft.DataMigration.GP;

table 41000 "GP GL00105"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; ACTINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; ACTNUMBR_1; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(3; ACTNUMBR_2; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(4; ACTNUMBR_3; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(5; ACTNUMBR_4; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(6; ACTNUMBR_5; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(7; ACTNUMBR_6; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(8; ACTNUMBR_7; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(9; ACTNUMBR_8; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(10; ACTNUMST; Text[129])
        {
            DataClassification = CustomerContent;
        }
        field(11; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; ACTINDX)
        {
            Clustered = true;
        }
    }
}