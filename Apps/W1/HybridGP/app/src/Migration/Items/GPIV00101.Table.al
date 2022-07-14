table 40116 "GP IV00101"
{
    Description = 'Item Master';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ITEMNMBR; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(14; IVIVINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(29; ITMCLSCD; Text[11])
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; ITEMNMBR)
        {
            Clustered = true;
        }
    }
}