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
                TableMetadata.Get("Table ID");
                "Table Name" := TableMetadata.Name;
                "Source Table Name" := TableMetadata.Name;
                Validate("Data Per Company", TableMetadata.DataPerCompany);
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
            begin
                ApplicationObjectMetadata.SetRange("Package ID", "Extension Package ID");
                ApplicationObjectMetadata.SetRange("Object Type", ApplicationObjectMetadata."Object Type"::Table);
                ApplicationObjectMetadata.SetCurrentKey("Object Name");
                ApplicationObjectMetadata.SetFilter("Object Name", StrSubstNo(TableNameFilterTxt, "Table Name"));
                if ApplicationObjectMetadata.FindFirst() then
                    Validate("Table ID", ApplicationObjectMetadata."Object ID")
                else
                    Error(InvalidTableNameErr);
            end;
        }

        field(4; "Source Table Name"; Text[128])
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies the name of the source table in the mapping.';
            NotBlank = true;
        }

        field(5; "Data Per Company"; Boolean)
        {
            DataClassification = SystemMetadata;
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
    }

    keys
    {
        key(PK; "App ID", "Table ID")
        {
            Clustered = true;
        }
    }

    var
        InvalidExtensionPublisherErr: Label 'Extensions from the specified Publisher are not enabled for custom table mapping.';
        InvalidTableNameErr: Label 'This table does not exist in the specified extension.';
        InvalidPublisherTxt: Label 'Microsoft', Locked = true;

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
        ExtensionNameFilterTxt: Label '@%1*', Comment = '%1 - name of extension', Locked = true;
    begin
        if ExtensionName <> '' then begin
            PublishedApplication.SetFilter(Name, StrSubstNo(ExtensionNameFilterTxt, ExtensionName));
            PublishedApplication.FindFirst();
            ExtensionName := PublishedApplication.Name;
            Validate("App ID", PublishedApplication.ID);
        end;
    end;
}