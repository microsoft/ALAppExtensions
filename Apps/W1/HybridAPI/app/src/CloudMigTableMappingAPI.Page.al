namespace Microsoft.DataMigration.API;

using Microsoft.DataMigration;

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

                field(targetTableType; Rec."Target Table Type")
                {
                    ApplicationArea = All;
                    Caption = 'tableType';
                    Description = 'Specifies the type of the target table.';
                    trigger OnValidate()
                    begin
                        Rec."Target Table Type" := Rec."Target Table Type";
                    end;
                }

                field(appId; Rec."App ID")
                {
                    ApplicationArea = All;
                    Caption = 'applicationID';
                }
                field(extensionName; Rec."Extension Name")
                {
                    ApplicationArea = All;
                    Caption = 'extensionName';
                    Editable = false;
                }

                field(tableId; tableID)
                {
                    ApplicationArea = All;
                    Caption = 'tableId';
                    trigger OnValidate()
                    begin
                        Rec."Table ID" := tableID;
                    end;
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

                field(dataPerCompany; Rec."Data Per Company")
                {
                    ApplicationArea = All;
                    Caption = 'dataPerCompany';
                    trigger OnValidate()
                    begin
                        Rec.TestField(Rec."Target Table Type", Rec."Target Table Type"::"Table Extension");
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        tableID := Rec."Table ID";
    end;

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

    var
        tableID: Integer;
}