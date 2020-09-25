table 1820 TempBlockedAccounts
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(13; Blocked; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

