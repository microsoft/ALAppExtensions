namespace Microsoft.DataMigration;

using System.Apps;
using System.Reflection;
using System.Utilities;

table 4009 "Migration Table Mapping"
{
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "App ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies the App ID to which the mapped table belongs.';
            TableRelation = "Published Application".ID;

            trigger OnValidate()
            var
                PublishedApp: Record "Published Application";
            begin
#pragma warning disable AA0210
                PublishedApp.SetRange(ID, "App ID");
#pragma warning restore
                PublishedApp.FindFirst();

                if Rec."Target Table Type" = Rec."Target Table Type"::Table then
                    if PublisherDenied(PublishedApp.Publisher) then
                        Error(InvalidExtensionPublisherErr);

                Clear("Table Name");
                Clear("Source Table Name");
                CalcFields("Extension Package ID");
                CalcFields("Extension Name");
            end;
        }

        field(2; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies the ID of the table to map.';
            NotBlank = true;

            trigger OnValidate()
            var
                TableMetadata: Record "Table Metadata";
            begin
                if Rec."Target Table Type" = Rec."Target Table Type"::"Table Extension" then
                    exit;

                TableMetadata.Get("Table ID");
                Rec."Table Name" := TableMetadata.Name;
                Rec."Source Table Name" := TableMetadata.Name;
                Rec.Validate("Data Per Company", TableMetadata.DataPerCompany);
            end;
        }

        field(3; "Table Name"; Text[30])
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies the name of the table to map.';
            NotBlank = true;

            trigger OnValidate()
            var
                ApplicationObjectMetadata: Record "Application Object Metadata";
                TableNameFilterTxt: Label '@%1*', Comment = '%1 - the table name', Locked = true;
                TableFound: Boolean;
            begin
                if Rec."Target Table Type" = Rec."Target Table Type"::"Table Extension" then
                    exit;

                ApplicationObjectMetadata.SetRange("Package ID", "Extension Package ID");

                if Rec."Target Table Type" = Rec."Target Table Type"::Table then
                    ApplicationObjectMetadata.SetRange("Object Type", ApplicationObjectMetadata."Object Type"::Table)
                else
                    ApplicationObjectMetadata.SetRange("Object Type", ApplicationObjectMetadata."Object Type"::"TableExtension");

                ApplicationObjectMetadata.SetCurrentKey("Object Name");
                ApplicationObjectMetadata.SetRange("Object Name", "Table Name");
                TableFound := ApplicationObjectMetadata.FindFirst();
                if not TableFound then begin
                    ApplicationObjectMetadata.SetFilter("Object Name", StrSubstNo(TableNameFilterTxt, "Table Name"));
                    TableFound := ApplicationObjectMetadata.FindFirst();
                end;

                if not TableFound then
                    Error(InvalidTableNameErr);

                Rec.Validate("Table ID", ApplicationObjectMetadata."Object ID")
            end;
        }

        field(4; "Source Table Name"; Text[128])
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies the name of the source table in the mapping.';
            NotBlank = true;

            trigger OnValidate()
            begin
#pragma warning disable AA0139
                Rec."Source Table Name" := Rec."Source Table Name".TrimEnd().TrimStart();
#pragma warning restore AA0139

                ValidateSourceTableName(Rec, Rec."Source Table Name")
            end;
        }

        field(5; "Data Per Company"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = true;
            Description = 'Specifies whether the data from the table is per company.';
        }

        field(6; Locked; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
            Description = 'Specifies whether to prevent users from modifying the table mapping record.';
        }

        field(8; "Extension Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Published Application".Name where(ID = field("App ID")));
        }

        field(9; "Extension Package ID"; Guid)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Published Application"."Package ID" where(ID = field("App ID")));
        }

        field(10; "Target Table Type"; Enum "Migration Table Type")
        {
            Description = 'Specifies the type of the target table.';
        }
    }
    keys
    {
        key(PK; "App ID", "Table ID")
        {
            Clustered = true;
        }
    }

    internal procedure ValidateSourceTableName(var MigrationTableMapping: Record "Migration Table Mapping"; SourceTableName: Text)
    var
        TrimmedSourceTableName: Text;
        TableDefinition: List of [Text];
        EndsWithGuid: Boolean;
        TestGuid: Guid;
    begin
        TrimmedSourceTableName := SourceTableName.Replace(OpeningSquareBracketLbl, '').Replace(ClosingSquareBracketLbl, '');
        if TrimmedSourceTableName.StartsWith(DboTok) then
            TrimmedSourceTableName := CopyStr(TrimmedSourceTableName, StrLen(DboTok) + 1, StrLen(TrimmedSourceTableName) - StrLen(DboTok));

        TableDefinition := TrimmedSourceTableName.Split(TableSepartorCharacterTok);
        if TableDefinition.Count() = 0 then
            exit;

        if TableDefinition.Count() = 1 then begin
            if SourceTableName.StartsWith(OpeningSquareBracketLbl) or SourceTableName.EndsWith(ClosingSquareBracketLbl) then begin
                MigrationTableMapping."Data Per Company" := false;
                MigrationTableMapping."Source Table Name" := CopyStr(TrimmedSourceTableName, 1, MaxStrLen(MigrationTableMapping."Source Table Name"));
            end;

            exit;
        end;

        EndsWithGuid := Evaluate(TestGuid, TableDefinition.Get(TableDefinition.Count()));
        MigrationTableMapping."Data Per Company" := IsTableNamePerCompany(SourceTableName, EndsWithGuid);

        if TableDefinition.Count() = 2 then
            if EndsWithGuid then
                MigrationTableMapping."Source Table Name" := CopyStr(TableDefinition.Get(1), 1, MaxStrLen(MigrationTableMapping."Source Table Name"))
            else
                MigrationTableMapping."Source Table Name" := CopyStr(TableDefinition.Get(2), 1, MaxStrLen(MigrationTableMapping."Source Table Name"));

        if TableDefinition.Count() = 3 then
            MigrationTableMapping."Source Table Name" := CopyStr(TableDefinition.Get(2), 1, MaxStrLen(MigrationTableMapping."Source Table Name"));

        if EndsWithGuid then
            MigrationTableMapping."Source Table Name" := CopyStr(MigrationTableMapping."Source Table Name" + TableSepartorCharacterTok + TableDefinition.Get(TableDefinition.Count()), 1, MaxStrLen(MigrationTableMapping."Source Table Name"));
    end;

    local procedure IsTableNamePerCompany(TableName: Text; EndsWithGuid: Boolean): Boolean
    var
        TableDefinition: List of [Text];
    begin
        TableDefinition := TableName.Split(TableSepartorCharacterTok);
        if TableDefinition.Count() < 2 then
            exit(true);

        if TableDefinition.Count() = 3 then
            exit(true);

        if not EndsWithGuid then
            exit(true);

        if (TableName.StartsWith(OpeningSquareBracketLbl) and TableName.EndsWith(ClosingSquareBracketLbl)) then
            exit(false);

        exit(true);
    end;

    local procedure PublisherDenied(ExtensionPublisher: Text): Boolean
    var
        InvalidPublishers: Text;
    begin
        InvalidPublishers := InvalidPublisherTxt;
        exit(InvalidPublishers.Split(',').Contains(ExtensionPublisher));
    end;

    procedure InvalidExtensionPublishers(): Text
    begin
        exit(InvalidPublisherTxt);
    end;

    procedure UpdateExtensionName(var ExtensionName: Text)
    var
        PublishedApplication: Record "Published Application";
    begin
        if ExtensionName <> '' then begin
            PublishedApplication.SetRange(Name, ExtensionName);
            if not PublishedApplication.FindFirst() then begin
                PublishedApplication.SetFilter(Name, '%1', '@' + ExtensionName + '*');
                PublishedApplication.FindFirst();
            end;

            ExtensionName := PublishedApplication.Name;
            Validate("App ID", PublishedApplication.ID);
        end;
    end;

    internal procedure LookupApp(var PublishedApplication: Record "Published Application"): Boolean
    var
        ExtensionManagement: Page "Extension Management";
    begin
        FilterOutBlacklistedPublishers(PublishedApplication);

        ExtensionManagement.SetTableView(PublishedApplication);
        ExtensionManagement.LookupMode(true);
        if not (ExtensionManagement.RunModal() in [Action::LookupOK, Action::OK]) then
            exit;

        ExtensionManagement.GetRecord(PublishedApplication);
        exit(true);
    end;

    internal procedure GetSourceTableAppID(var MigrationTableMapping: Record "Migration Table Mapping"): Text
    begin
        exit(MigrationTableMapping.GetSourceTableAppID(MigrationTableMapping."Source Table Name"));
    end;

    internal procedure GetSourceTableAppID(SourceTableName: Text): Text
    var
        ExtensionIndex: Integer;
    begin
        if SourceTableName = '' then
            exit('');

        ExtensionIndex := SourceTableName.IndexOf(GetExtensionSeparatorCharacter());
        if ExtensionIndex = 0 then
            exit('');

        exit(CopyStr(SourceTableName, ExtensionIndex + 1, StrLen(SourceTableName) - ExtensionIndex));
    end;

    internal procedure GetSourceTableName(var MigrationTableMapping: Record "Migration Table Mapping"): Text
    begin
        exit(ParseSourceTableName(MigrationTableMapping."Source Table Name"));
    end;

    internal procedure ParseSourceTableName(SourcetableName: Text): Text
    var
        ExtensionIndex: Integer;
    begin
        if SourcetableName = '' then
            exit('');

        ExtensionIndex := SourcetableName.IndexOf(GetExtensionSeparatorCharacter());
        if ExtensionIndex = 0 then
            exit(SourcetableName);

        exit(CopyStr(SourcetableName, 1, ExtensionIndex - 1));
    end;

    internal procedure GetExtensionSeparatorCharacter(): Text
    begin
        exit('$');
    end;

    internal procedure FilterOutBlacklistedPublishers(var PublishedApplication: Record "Published Application")
    var
        BlacklistExtensionFilter: Text;
        BlacklistPublisher: Text;
        BlacklistFilterTxt: Label '<>%1&', Comment = '%1 - extension publisher', Locked = true;
    begin
        foreach BlacklistPublisher in InvalidExtensionPublishers().Split(',') do
            BlacklistExtensionFilter += StrSubstNo(BlacklistFilterTxt, BlacklistPublisher);

        BlacklistExtensionFilter := BlacklistExtensionFilter.TrimEnd('&');
        PublishedApplication.SetFilter(Publisher, BlacklistExtensionFilter);
    end;

    internal procedure SetSourceTableName(SourceTableAppID: Text)
    var
        BlankGuid: Guid;
    begin
        if SourceTableAppID = '' then begin
            Rec."Source Table Name" := CopyStr(Rec.GetSourceTableName(Rec), 1, MaxStrLen(Rec."Source Table Name"));
            exit;
        end;

        Evaluate(BlankGuid, SourceTableAppID);
        SourceTableAppID := SourceTableAppID.TrimStart('{').TrimEnd('}');
        Rec."Source Table Name" := CopyStr(Rec.GetSourceTableName(Rec) + Rec.GetExtensionSeparatorCharacter() + SourceTableAppID, 1, MaxStrLen(Rec."Source Table Name"))
    end;

    procedure ImportMigrationTableMappings()
    var
        MigrationTableMapping: Record "Migration Table Mapping";
        TableMappingJsonArray: JsonArray;
        AllTableMappingsJsonObject: JsonObject;
        TableMappingsJsonToken: JsonToken;
        TableMappingsJsonObject: JsonObject;
        JsonInStream: InStream;
        FileName: Text;
    begin
        FileName := TableMappingDefinitionJsonFileNameTxt;

        if not UploadIntoStream(ImportTableMappingsDialogLbl, '', 'All Files (*.*)|*.*', FileName, JsonInStream) then
            exit;

        AllTableMappingsJsonObject.ReadFrom(JsonInStream);
        AllTableMappingsJsonObject.Get(ValuesTok, TableMappingsJsonToken);
        TableMappingJsonArray := TableMappingsJsonToken.AsArray();

        foreach TableMappingsJsonToken in TableMappingJsonArray do begin
            TableMappingsJsonObject := TableMappingsJsonToken.AsObject();
            MigrationTableMapping.ImportFromJson(TableMappingsJsonObject);
        end;
    end;

    procedure ImportFromJson(TableMappingsJsonObject: JsonObject)
    var
        MigrationTableMapping: Record "Migration Table Mapping";
        TableMappingsFieldToken: JsonToken;
        CurrentGlobalLanguage: Integer;
    begin
        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(1033); // ENU

        if TableMappingsJsonObject.Get(TargetTableTypeLbl, TableMappingsFieldToken) then
            Evaluate(MigrationTableMapping."Target Table Type", TableMappingsFieldToken.AsValue().AsText());

        if TableMappingsJsonObject.Get(AppIdLbl, TableMappingsFieldToken) then
            MigrationTableMapping.Validate("App Id", TableMappingsFieldToken.AsValue().AsText());

        if TableMappingsJsonObject.Get(TargetTableIdLbl, TableMappingsFieldToken) then
            MigrationTableMapping.Validate("Table Id", TableMappingsFieldToken.AsValue().AsInteger());

        if TableMappingsJsonObject.Get(TargetTableNameLbl, TableMappingsFieldToken) then
            MigrationTableMapping.Validate("Table Name", TableMappingsFieldToken.AsValue().AsText());

        if TableMappingsJsonObject.Get(SourceTableNameLbl, TableMappingsFieldToken) then
            MigrationTableMapping.Validate("Source Table Name", TableMappingsFieldToken.AsValue().AsText());

        if TableMappingsJsonObject.Get(DataPerCompanyLbl, TableMappingsFieldToken) then
            MigrationTableMapping.Validate("Data Per Company", TableMappingsFieldToken.AsValue().AsBoolean());

        if TableMappingsJsonObject.Get(IdLbl, TableMappingsFieldToken) then begin
            MigrationTableMapping.SystemId := TableMappingsFieldToken.AsValue().AsText();
            MigrationTableMapping.Insert(true, true);
        end else
            MigrationTableMapping.Insert(true);

        GlobalLanguage(CurrentGlobalLanguage);
    end;

    procedure DownloadMigrationTableMappings()
    var
        TempBlob: Codeunit "Temp Blob";
        AllTableMappingsJson: JsonObject;
        JsonOutStream: OutStream;
        JsonInStream: InStream;
        FileName: Text;
    begin
        AllTableMappingsJson := ExportMigrationTableMappings();
        TempBlob.CreateOutStream(JsonOutStream);
        AllTableMappingsJson.WriteTo(JsonOutStream);
        TempBlob.CreateInStream(JsonInStream);

        FileName := TableMappingDefinitionJsonFileNameTxt;
        DownloadFromStream(JsonInStream, ExportTableMappingsDialogLbl, '', '*.json', FileName);
    end;

    procedure ExportMigrationTableMappings(): JsonObject
    var
        MigrationTableMapping: Record "Migration Table Mapping";
        AllTableMappingObject: JsonObject;
        TableMappingJsonArray: JsonArray;
    begin
        if MigrationTableMapping.FindSet() then
            repeat
                TableMappingJsonArray.Add(MigrationTableMapping.ExportFromJson(MigrationTableMapping))
            until MigrationTableMapping.Next() = 0;

        AllTableMappingObject.Add(ValuesTok, TableMappingJsonArray);
        exit(AllTableMappingObject);
    end;

    procedure ExportFromJson(var MigrationTableMapping: Record "Migration Table Mapping"): JsonObject
    var
        TableMappingsJsonObject: JsonObject;
        CurrentGlobalLanguage: Integer;
    begin
        CurrentGlobalLanguage := GlobalLanguage();

        TableMappingsJsonObject.Add(IdLbl, LowerCase(Format(MigrationTableMapping.SystemId).TrimStart('{').TrimEnd('}')));
        TableMappingsJsonObject.Add(TargetTableTypeLbl, Format(MigrationTableMapping."Target Table Type"));
        TableMappingsJsonObject.Add(AppIdLbl, LowerCase(Format(MigrationTableMapping."App ID").TrimStart('{').TrimEnd('}')));
        TableMappingsJsonObject.Add(TargetTableIdLbl, MigrationTableMapping."Table ID");
        TableMappingsJsonObject.Add(TargetTableNameLbl, MigrationTableMapping."Table Name");
        TableMappingsJsonObject.Add(SourceTableNameLbl, MigrationTableMapping."Source Table Name");
        TableMappingsJsonObject.Add(DataPerCompanyLbl, MigrationTableMapping."Data Per Company");

        GlobalLanguage(1033); // ENU
        GlobalLanguage(CurrentGlobalLanguage);

        exit(TableMappingsJsonObject);
    end;

    var
        InvalidExtensionPublisherErr: Label 'Extensions from the specified Publisher are not enabled for custom table mapping.';
        InvalidTableNameErr: Label 'This table does not exist in the specified extension.';
        InvalidPublisherTxt: Label 'Microsoft', Locked = true;
        TargetTableTypeLbl: Label 'targetTableType', Locked = true;
        TargetTableIdLbl: Label 'tableId', Locked = true;
        TargetTableNameLbl: Label 'tableName', Locked = true;
        SourceTableNameLbl: Label 'sourceTableName', Locked = true;
        DataPerCompanyLbl: Label 'dataPerCompany', Locked = true;
        AppIdLbl: Label 'appId', Locked = true;
        IdLbl: Label 'id', Locked = true;
        ValuesTok: Label 'values', Locked = true;
        TableMappingDefinitionJsonFileNameTxt: Label 'TableMappingDefinition.json', Locked = true;
        ExportTableMappingsDialogLbl: Label 'Export';
        ImportTableMappingsDialogLbl: Label 'Import';
        TableSepartorCharacterTok: Label '$', Locked = true;
        OpeningSquareBracketLbl: Label '[', Locked = true;
        ClosingSquareBracketLbl: Label ']', Locked = true;
        DboTok: Label 'dbo.', Locked = true;
}