table 4766 "Manufacturing Module Setup"
{
    DataClassification = CustomerContent;
    InherentEntitlements = RMX;
    InherentPermissions = RMX;
    Extensible = false;
    DataPerCompany = true;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Manufacturing Location"; code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Location" where("Use As In-Transit" = const(false));
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    [InherentPermissions(PermissionObjectType::TableData, Database::"Manufacturing Module Setup", 'I')]
    internal procedure InitRecord()
    begin
        if Rec.Get() then
            exit;

        Rec.Init();
        Rec.Insert();
    end;
}