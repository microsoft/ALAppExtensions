table 132525 "Edit In Excel Test Table"
{
    fields
    {
        field(1; "No."; Code[20])
        {
        }

        field(2; MyField; Blob)
        {
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}