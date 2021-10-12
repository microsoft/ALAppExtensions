table 19300 "India Migration Worksheet"
{
    fields
    {
        field(1; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "To Table ID"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; Commited; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Start Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(5; "End Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(6; Status; Enum "Migration Status")
        {
            DataClassification = CustomerContent;
        }
        field(7; "Error Text"; Text[2000])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table ID")
        {
            Clustered = true;
        }
    }
}