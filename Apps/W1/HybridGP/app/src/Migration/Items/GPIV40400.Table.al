namespace Microsoft.DataMigration.GP;

table 40117 "GP IV40400"
{
    Description = 'Item Class Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ITMCLSCD; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(2; ITMCLSDC; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(27; IVIVINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; ITMCLSCD)
        {
            Clustered = true;
        }
    }
}