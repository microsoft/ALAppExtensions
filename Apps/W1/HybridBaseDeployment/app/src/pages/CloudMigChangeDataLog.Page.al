namespace Microsoft.DataMigration;

page 40042 "Cloud Mig Change Data Log"
{
    PageType = List;
    SourceTable = "Cloud Migration Override Log";
    Caption = 'Changes to data migration setup';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting("Primary Key") order(descending);

    layout
    {
        area(Content)
        {
            repeater(MigrationLog)
            {
                field(TableName; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    ToolTip = 'Specifies the name of the destination table.';
                }
                field(CompanyName; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                    ToolTip = 'Specifies the Company Name of the destination table.';
                }
                field("Table Id"; Rec."Table Id")
                {
                    ApplicationArea = All;
                    Caption = 'Table Id';
                    ToolTip = 'Specifies the Table Id of the destination table.';
                }
                field("Replicate Data"; Rec."Replicate Data")
                {
                    ApplicationArea = All;
                    Caption = 'Replicate Data';
                    ToolTip = 'Specifies if the data should be replicated to SaaS.';
                }
                field("Preserve Cloud Data"; Rec."Preserve Cloud Data")
                {
                    ApplicationArea = All;
                    Caption = 'Preserve Cloud Data';
                    ToolTip = 'Specifies if the data in the destination table should be preserved or replaced with the data from the source table.';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                    Caption = 'Last Modified Date Time';
                    ToolTip = 'Specifies the date and time when the record was last modified.';
                }
            }
        }
    }
}