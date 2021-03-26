table 18814 "TCS Setup"
{
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "ID"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Tax Type"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Tax Type";
        }
    }

    keys
    {
        key(PK; "ID")
        {
            Clustered = true;
        }
    }
}