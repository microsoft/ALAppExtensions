page 40026 "Cloud Mig Status Detail API"
{
    PageType = API;
    SourceTable = "Hybrid Replication Detail";
    APIGroup = 'cloudMigration';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Cloud Migration Status Detail';
    EntitySetCaption = 'Cloud Migration Status Details';
    EntitySetName = 'cloudMigrationStatusDetails';
    EntityName = 'cloudMigrationStatusDetail';
    DelayedInsert = true;
    Extensible = false;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    Editable = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'id';
                }
                field(runId; Rec."Run ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'id';
                }

                field(companyName; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'id';
                }
                field(tableName; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Table Name';
                }
                field(status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Status';
                }
                field(recordsCopied; Rec."Records Copied")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Records Copied';
                }
                field(totalRecords; Rec."Total Records")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Total Copied';
                }
                field(errors; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Records Copied';
                }
            }
        }
    }
}