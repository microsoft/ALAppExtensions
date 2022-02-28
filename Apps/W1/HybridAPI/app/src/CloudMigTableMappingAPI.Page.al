page 40022 "Cloud Mig Table Mapping API"
{
    PageType = API;
    SourceTable = "Migration Table Mapping";
    APIGroup = 'cloudMigration';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Cloud Migration Table Mapping';
    EntitySetCaption = 'Cloud Migration Table Mappings';
    EntitySetName = 'tableMappings';
    EntityName = 'tableMapping';
    DelayedInsert = true;
    Extensible = false;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'id';
                }

                field(tableId; Rec."Table ID")
                {
                    ApplicationArea = All;
                    Caption = 'tableId';
                }

                field(tableName; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'tableName';
                }

                field(sourceTableName; Rec."Source Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'sourceTableName';
                }

                field(extensionName; Rec."Extension Name")
                {
                    ApplicationArea = All;
                    Caption = 'extensionName';

                    trigger OnValidate()
                    begin
                        Rec.UpdateExtensionName(Rec."Extension Name");
                    end;
                }
            }
        }
    }

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure RestoreDefaults(var ActionContext: WebServiceActionContext)
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.RestoreDefaultMigrationTableMappings(true);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure DeleteAllForExtension(var ActionContext: WebServiceActionContext)
    var
        MigrationTableMapping: Record "Migration Table Mapping";
    begin
        MigrationTableMapping.SetRange("App ID", Rec."App ID");
        MigrationTableMapping.DeleteAll();
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;
}