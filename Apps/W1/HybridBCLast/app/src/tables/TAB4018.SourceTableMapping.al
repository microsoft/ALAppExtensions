table 4018 "Source Table Mapping"
{
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "Source Table Name"; Text[128])
        {
            DataClassification = SystemMetadata;
        }

        field(2; "Country Code"; Code[10])
        {
            DataClassification = SystemMetadata;
        }

        field(3; "Destination Table Name"; Text[128])
        {
            DataClassification = SystemMetadata;
        }
        field(4; Staged; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Indicates whether the table must go through a temporary staging table.';
        }
        field(5; "App Id"; Guid)
        {
            DataClassification = SystemMetadata;
            Description = 'The id of the extension that created the mapping.';
        }
    }

    keys
    {
        key(Key1; "Source Table Name", "Country Code", "Destination Table Name")
        {
        }
    }

    procedure MapTable(SourceTableName: Text; CountryCode: Code[10]; DestinationTableName: Text; Staged: Boolean; SourceAppId: Guid; AppId: Guid)
    begin
        SourceTableName := SourceTableName + '$' + LowerCase(DelChr(SourceAppId, '<>', '{}'));
        MapTable(SourceTableName, CountryCode, DestinationTableName, Staged, AppId);
    end;

    procedure MapTable(SourceTableName: Text; CountryCode: Code[10]; DestinationTableName: Text; Staged: Boolean; AppId: Guid)
    var
        SourceTableMapping: Record "Source Table Mapping";
        Exists: Boolean;
    begin
        Exists := SourceTableMapping.Get(SourceTableName, CountryCode);
        if not Exists then begin
            SourceTableMapping.Init();
            SourceTableMapping."Source Table Name" := CopyStr(SourceTableName, 1, 128);
            SourceTableMapping."Country Code" := CountryCode;
        end;

        SourceTableMapping."Destination Table Name" := CopyStr(DestinationTableName, 1, 128);
        SourceTableMapping."App Id" := AppId;
        SourceTableMapping.Staged := Staged;

        if Exists then
            SourceTableMapping.Modify()
        else
            SourceTableMapping.Insert();
    end;

    procedure SqlTableName(PerCompany: Boolean) Name: Text
    begin
        if PerCompany then
            Name := CompanyName() + '$' + "Source Table Name"
        else
            Name := "Source Table Name";

        Name := ConvertStr(Name, '."\/''%][', '________');
    end;
}