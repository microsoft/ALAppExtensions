// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

using System.Utilities;

/// <summary>
/// Temporary table that combines data from Migration Setup Table Mapping and Replication Table Mapping tables.
/// Used for displaying and managing all table mappings in a single view.
/// </summary>
table 40035 "Custom Migration Table Buffer"
{
    DataClassification = SystemMetadata;
    TableType = Temporary;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "Source Sql Table Name"; Text[128])
        {
            Caption = 'Source SQL Table Name';
            ToolTip = 'Specifies the name of the source SQL table to be replicated. The name must match exactly the name of the destination table in SQL.';
        }

        field(2; "Destination Sql Table Name"; Text[128])
        {
            Caption = 'Destination SQL Table Name';
            ToolTip = 'Specifies the name of the destination SQL table in the cloud environment. The name must match exactly the name of the destination table in SQL.';
        }

        field(3; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            ToolTip = 'Specifies the company name associated with this table mapping. The value should be blank if the table is per-database.';
        }

        field(4; "Table Name"; Text[128])
        {
            Caption = 'Table Name';
            ToolTip = 'Specifies the name of the table. For example, "Customer" or "Sales Header".';
        }

        field(5; "Preserve Cloud Data"; Boolean)
        {
            Caption = 'Preserve Cloud Data';
            ToolTip = 'Specifies whether to preserve existing data in the cloud during replication. If set to true, existing data in the destination table will not be overwritten during replication, only new records will be added. It is recommended to set this to true for per-database table, while it should be false for per-company tables.';
        }

        field(6; "Mapping Type"; Enum "Migration Mapping Type")
        {
            Caption = 'Mapping Type';
            ToolTip = 'Specifies whether this mapping is for Replication or Migration Setup.';
        }
    }

    keys
    {
        key(Key1; "Source Sql Table Name", "Destination Sql Table Name")
        {
            Clustered = true;
        }
        key(Key2; "Mapping Type", "Table Name")
        {
        }
        key(Key3; "Destination Sql Table Name")
        {
            Unique = true;
        }
    }

    trigger OnDelete()
    begin
        PropagateDelete(Rec);
    end;

    procedure LoadData()
    var
        MigrationSetupTableMapping: Record "Migration Setup Table Mapping";
        ReplicationTableMapping: Record "Replication Table Mapping";
    begin
        Rec.Reset();
        Rec.DeleteAll();

        if MigrationSetupTableMapping.FindSet() then
            repeat
                Clear(Rec);
                Rec."Mapping Type" := Rec."Mapping Type"::"Migration Setup";
                Rec."Source Sql Table Name" := MigrationSetupTableMapping."Source Sql Table Name";
                Rec."Destination Sql Table Name" := MigrationSetupTableMapping."Destination Sql Table Name";
                Rec."Company Name" := MigrationSetupTableMapping."Company Name";
                Rec."Table Name" := MigrationSetupTableMapping."Table Name";
                Rec."Preserve Cloud Data" := MigrationSetupTableMapping."Preserve Cloud Data";
                Rec.Insert();
            until MigrationSetupTableMapping.Next() = 0;

        if ReplicationTableMapping.FindSet() then
            repeat
                Clear(Rec);
                Rec."Mapping Type" := Rec."Mapping Type"::Replication;
                Rec."Source Sql Table Name" := ReplicationTableMapping."Source Sql Table Name";
                Rec."Destination Sql Table Name" := ReplicationTableMapping."Destination Sql Table Name";
                Rec."Company Name" := ReplicationTableMapping."Company Name";
                Rec."Table Name" := ReplicationTableMapping."Table Name";
                Rec."Preserve Cloud Data" := ReplicationTableMapping."Preserve Cloud Data";
                Rec.Insert();
            until ReplicationTableMapping.Next() = 0;
    end;

    procedure ExportToJson(): Text
    var
        TableMappingsJsonArray: JsonArray;
        TableMappingJsonObject: JsonObject;
        ResultText: Text;
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(1033); // en-US

        Rec.Reset();
        if Rec.FindSet() then
            repeat
                Clear(TableMappingJsonObject);
                TableMappingJsonObject.Add(MappingTypeTok, Format(Rec."Mapping Type"));
                TableMappingJsonObject.Add(SourceSqlTableNameTok, Rec."Source Sql Table Name");
                TableMappingJsonObject.Add(DestinationSqlTableNameTok, Rec."Destination Sql Table Name");
                TableMappingJsonObject.Add(CompanyNameTok, Rec."Company Name");
                TableMappingJsonObject.Add(TableNameTok, Rec."Table Name");
                TableMappingJsonObject.Add(PreserveCloudDataTok, Rec."Preserve Cloud Data");
                TableMappingsJsonArray.Add(TableMappingJsonObject);
            until Rec.Next() = 0;

        TableMappingsJsonArray.WriteTo(ResultText);
        GlobalLanguage(CurrentLanguage);
        exit(ResultText);
    end;

    procedure ImportFromJson(JsonText: Text)
    var
        MigrationSetupTableMapping: Record "Migration Setup Table Mapping";
        ReplicationTableMapping: Record "Replication Table Mapping";
        TableMappingsJsonArray: JsonArray;
        TableMappingJsonToken: JsonToken;
        TableMappingJsonObject: JsonObject;
        MappingTypeText: Text;
        CurrentLanguage: Integer;
        i: Integer;
    begin
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(1033); // en-US

        if not TableMappingsJsonArray.ReadFrom(JsonText) then begin
            GlobalLanguage(CurrentLanguage);
            exit;
        end;

        for i := 0 to TableMappingsJsonArray.Count() - 1 do begin
            TableMappingsJsonArray.Get(i, TableMappingJsonToken);
            TableMappingJsonObject := TableMappingJsonToken.AsObject();

            MappingTypeText := GetJsonValueSafe(TableMappingJsonObject, MappingTypeTok);

            if MappingTypeText = Format(Rec."Mapping Type"::"Migration Setup") then begin
                if MigrationSetupTableMapping.Get(GetJsonValueSafe(TableMappingJsonObject, SourceSqlTableNameTok), GetJsonValueSafe(TableMappingJsonObject, DestinationSqlTableNameTok)) then
                    MigrationSetupTableMapping.Delete(true);

                Clear(MigrationSetupTableMapping);
#pragma warning disable AA0139
                MigrationSetupTableMapping."Source Sql Table Name" := GetJsonValueSafe(TableMappingJsonObject, SourceSqlTableNameTok);
                MigrationSetupTableMapping."Destination Sql Table Name" := GetJsonValueSafe(TableMappingJsonObject, DestinationSqlTableNameTok);
                MigrationSetupTableMapping."Company Name" := GetJsonValueSafe(TableMappingJsonObject, CompanyNameTok);
                MigrationSetupTableMapping."Table Name" := GetJsonValueSafe(TableMappingJsonObject, TableNameTok);
#pragma warning restore AA0139
                Evaluate(MigrationSetupTableMapping."Preserve Cloud Data", GetJsonValueSafe(TableMappingJsonObject, PreserveCloudDataTok));
                MigrationSetupTableMapping.Insert(true);
            end else begin
                if ReplicationTableMapping.Get(GetJsonValueSafe(TableMappingJsonObject, SourceSqlTableNameTok), GetJsonValueSafe(TableMappingJsonObject, DestinationSqlTableNameTok)) then
                    ReplicationTableMapping.Delete(true);

                Clear(ReplicationTableMapping);
#pragma warning disable AA0139
                ReplicationTableMapping."Source Sql Table Name" := GetJsonValueSafe(TableMappingJsonObject, SourceSqlTableNameTok);
                ReplicationTableMapping."Destination Sql Table Name" := GetJsonValueSafe(TableMappingJsonObject, DestinationSqlTableNameTok);
                ReplicationTableMapping."Company Name" := GetJsonValueSafe(TableMappingJsonObject, CompanyNameTok);
                ReplicationTableMapping."Table Name" := GetJsonValueSafe(TableMappingJsonObject, TableNameTok);
#pragma warning restore AA0139
                Evaluate(ReplicationTableMapping."Preserve Cloud Data", GetJsonValueSafe(TableMappingJsonObject, PreserveCloudDataTok));
                ReplicationTableMapping.Insert(true);
            end;
        end;

        GlobalLanguage(CurrentLanguage);
        LoadData();
    end;

    local procedure PropagateDelete(var CustomMigrationTableBuffer: Record "Custom Migration Table Buffer")
    var
        MigrationSetupTableMapping: Record "Migration Setup Table Mapping";
        ReplicationTableMapping: Record "Replication Table Mapping";
    begin
        case CustomMigrationTableBuffer."Mapping Type" of
            CustomMigrationTableBuffer."Mapping Type"::"Migration Setup":
                if MigrationSetupTableMapping.Get(CustomMigrationTableBuffer."Source Sql Table Name", CustomMigrationTableBuffer."Destination Sql Table Name") then
                    MigrationSetupTableMapping.Delete(true);
            CustomMigrationTableBuffer."Mapping Type"::Replication:
                if ReplicationTableMapping.Get(CustomMigrationTableBuffer."Source Sql Table Name", CustomMigrationTableBuffer."Destination Sql Table Name") then
                    ReplicationTableMapping.Delete(true);
        end;
    end;

    local procedure GetJsonValueSafe(ParentJsonObject: JsonObject; PropertyName: Text): Text
    var
        ObjectJsonToken: JsonToken;
    begin
        ParentJsonObject.Get(PropertyName, ObjectJsonToken);
        exit(ObjectJsonToken.AsValue().AsText());
    end;

    internal procedure GetDefaultEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

    internal procedure ExportToFile()
    var
        TempBlob: Codeunit "Temp Blob";
        JsonOutStream: OutStream;
        JsonInStream: InStream;
        JsonText: Text;
        FileName: Text;
    begin
        JsonText := ExportToJson();
        TempBlob.CreateOutStream(JsonOutStream, GetDefaultEncoding());
        JsonOutStream.WriteText(JsonText);
        TempBlob.CreateInStream(JsonInStream, GetDefaultEncoding());
        FileName := DefaultFileNameTok;
        DownloadFromStream(JsonInStream, ExportDialogTitleLbl, '', JsonFileFilterTok, FileName);
    end;

    internal procedure RestoreDefaultMappings()
    var
        MigrationSetupTableMapping: Record "Migration Setup Table Mapping";
        ReplicationTableMapping: Record "Replication Table Mapping";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        CustomMigrationProvider: Interface "Custom Migration Provider";
    begin
        MigrationSetupTableMapping.DeleteAll(true);
        ReplicationTableMapping.DeleteAll(true);

        IntelligentCloudSetup.Get();
        CustomMigrationProvider := IntelligentCloudSetup."Custom Migration Provider";
        CustomMigrationProvider.SetupMigrationSetupTableMappings();
        CustomMigrationProvider.SetupReplicationTableMappings();

        LoadData();
    end;

    procedure SaveMigrationTableMapping(MappingType: Enum "Migration Mapping Type"; SourceTableName: Text[128]; DestinationTableName: Text[128]; TargetTableName: Text[128]; CompanyName: Text[30]; DataPerCompany: Boolean; PreserveCloudData: Boolean)
    var
        MigrationSetupTableMapping: Record "Migration Setup Table Mapping";
        ReplicationTableMapping: Record "Replication Table Mapping";
        CompanyNameValue: Text[30];
    begin
        CompanyNameValue := CopyStr(DataPerCompany ? CompanyName : '', 1, MaxStrLen(CompanyNameValue));

        case MappingType of
            MappingType::"Migration Setup":
                begin
                    if MigrationSetupTableMapping.Get(SourceTableName, DestinationTableName) then
                        MigrationSetupTableMapping.Delete(true);

                    MigrationSetupTableMapping."Source Sql Table Name" := SourceTableName;
                    MigrationSetupTableMapping."Destination Sql Table Name" := DestinationTableName;
                    MigrationSetupTableMapping."Table Name" := TargetTableName;
                    MigrationSetupTableMapping."Company Name" := CompanyNameValue;
                    MigrationSetupTableMapping."Preserve Cloud Data" := PreserveCloudData;
                    MigrationSetupTableMapping.Insert(true);
                end;
            MappingType::Replication:
                begin
                    ReplicationTableMapping."Source Sql Table Name" := SourceTableName;
                    ReplicationTableMapping."Destination Sql Table Name" := DestinationTableName;
                    ReplicationTableMapping."Table Name" := TargetTableName;
                    ReplicationTableMapping."Company Name" := CompanyNameValue;
                    ReplicationTableMapping."Preserve Cloud Data" := PreserveCloudData;

                    if not ReplicationTableMapping.Insert(true) then
                        ReplicationTableMapping.Modify(true);
                end;
        end;
    end;

    var
        MappingTypeTok: Label 'mappingType', Locked = true;
        SourceSqlTableNameTok: Label 'sourceSqlTableName', Locked = true;
        DestinationSqlTableNameTok: Label 'destinationSqlTableName', Locked = true;
        CompanyNameTok: Label 'companyName', Locked = true;
        TableNameTok: Label 'tableName', Locked = true;
        PreserveCloudDataTok: Label 'preserveCloudData', Locked = true;
        DefaultFileNameTok: Label 'TableMappings.json', Locked = true;
        JsonFileFilterTok: Label '*.json', Locked = true;
        ExportDialogTitleLbl: Label 'Export Table Mappings';
}
