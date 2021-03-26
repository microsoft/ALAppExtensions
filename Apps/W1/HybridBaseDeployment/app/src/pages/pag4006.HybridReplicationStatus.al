page 4006 "Intelligent Cloud Details"
{
    Caption = 'Table Migration Status';
    SourceTable = "Hybrid Replication Detail";
    PageType = List;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting(Status, "Company Name", "Table Name") order(ascending);

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company of the table.';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the table.';
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the table.';
                }
                field("Records Copied"; GetCopiedRecords())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Records Migrated';
                    ToolTip = 'Specifies the number of records in the table that have been migrated.';
                    Visible = ShowRecordCounts;
                }
                field("Total Records"; "Total Records")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total number of records to copy from the source table.';
                    Visible = ShowRecordCounts;
                }
                field(Errors; "Error Message")
                {
                    Caption = 'Message';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies any errors that happened during the migration.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // If any tables have "Records Copied" > 0, then we show the field.
        if not ShowRecordCounts then
            ShowRecordCounts := "Records Copied" > 0;
    end;

    var
        ShowRecordCounts: Boolean;
}