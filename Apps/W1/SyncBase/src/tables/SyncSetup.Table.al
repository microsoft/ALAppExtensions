namespace Microsoft.Integration.SyncBase;

table 2400 "Sync Setup"
{
    Caption = 'Sync Setup';
    DataClassification = SystemMetadata;
    ReplicateData = false;
#if not CLEAN24
    ObsoleteState = Pending;
    ObsoleteReason = 'The extension is being obsoleted.';
    ObsoleteTag = '24.0';
#else
    ObsoleteState = Removed;
    ObsoleteReason = 'The extension is being obsoleted.';
    ObsoleteTag = '27.0';
#endif

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

#if not CLEAN24
    [Obsolete('The extension is being obsoleted.', '24.0')]
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
#endif
}

