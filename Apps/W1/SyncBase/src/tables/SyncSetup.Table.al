table 2400 "Sync Setup"
{
    Caption = 'Sync Setup';
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[1])
        {
        }
        field(2; "Last Sync Time"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Current Sync Time"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Max No. of sync attempts"; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    [Scope('Personalization')]
    procedure GetSingleInstance()
    begin
        if Get() then
            exit;

        Init();
        SetMaxNumberOfSyncAttempts();
        Insert();
    end;

    local procedure SetMaxNumberOfSyncAttempts()
    begin
        "Max No. of sync attempts" := 10;
    end;
}

