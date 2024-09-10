namespace Microsoft.DataMigration.GP;

table 41007 "GP IV00104"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; ITEMNMBR; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(2; SEQNUMBR; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; CMPTITNM; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(4; CMPITUOM; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(5; CMPITQTY; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; CMPSERNM; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(7; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; ITEMNMBR, CMPTITNM, CMPITUOM)
        {
            Clustered = true;
        }
    }
}
