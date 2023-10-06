table 4043 "Stg Data Exch Def US"
{
    ReplicateData = false;
    Extensible = false;
#if not CLEAN21
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '21.0';
#else
    ObsoleteState = Removed;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '24.0';
#endif
    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; Type; Enum "Data Exchange Definition Type")
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}