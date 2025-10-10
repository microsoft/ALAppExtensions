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
        field(28; IVIVOFIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(29; IVCOGSIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(30; IVSLSIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(31; IVSLDSIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(32; IVSLRNIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(33; IVINUSIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(34; IVINSVIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(35; IVDMGIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(36; IVVARIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(37; DPSHPIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(38; PURPVIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(39; UPPVIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(40; IVRETIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(41; ASMVRIDX; Integer)
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