namespace Microsoft.DataMigration;

table 40041 "Cloud Migration Override Log"
{
    DataClassification = SystemMetadata;
    ReplicateData = false;
    Scope = OnPrem;
    Access = Internal;

    fields
    {
        field(1; "Table Name"; Text[250])
        {
            Caption = 'SQL Table Name';
        }
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
        }
        field(3; "Table Id"; Integer)
        {
            Caption = 'Table Id';
        }
        field(4; "Synced Version"; BigInteger)
        {
            Caption = 'Synced Version';
        }
        field(5; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(6; "Replicate Data"; Boolean)
        {
            Caption = 'Replicate Data';
        }
        field(7; "Preserve Cloud Data"; Boolean)
        {
            Caption = 'Preserve Cloud Data';
        }
        field(8000; "Primary Key"; Integer)
        {
            AutoIncrement = true;
        }
        field(8001; "Change Type"; Option)
        {
            Caption = 'Change Type';
            OptionCaption = ' ,Initial Entry,Modified,Reset to Default';
            OptionMembers = " ","Initial Entry","Modified","Reset to Default";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}