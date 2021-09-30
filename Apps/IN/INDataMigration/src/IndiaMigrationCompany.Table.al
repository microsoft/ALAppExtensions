table 19299 "India Migration Company"
{
    DataPerCompany = false;
    DataClassification = CustomerContent;
    fields
    {
        field(1; Name; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(2; Status; Enum "Migration Status")
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }
}