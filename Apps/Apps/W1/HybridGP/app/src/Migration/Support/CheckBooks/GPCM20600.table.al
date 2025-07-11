namespace Microsoft.DataMigration.GP;

table 40109 "GP CM20600"
{
    DataClassification = CustomerContent;
    Description = 'Transfers';

    fields
    {
        field(1; Xfr_Record_Number; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(2; CMXFRNUM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(3; CMFRMRECNUM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(4; CMTORECNUM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(5; CMFRMSTATUS; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; CMTOSTATUS; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(7; CMFRMCHKBKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(8; CMCHKBKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(9; CMXFTDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(10; NOTEINDX; Decimal)
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
        key(Key1; Xfr_Record_Number)
        {
            Clustered = true;
        }
    }
}