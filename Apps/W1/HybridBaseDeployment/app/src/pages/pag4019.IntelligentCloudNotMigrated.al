page 4019 "Intelligent Cloud Not Migrated"
{
    Caption = 'Cloud Migration Tables Not Migrated';
    SourceTable = "Intelligent Cloud Not Migrated";
    SourceTableTemporary = true;
    PageType = List;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company name for the table.';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the table.';
                }
            }
        }
    }
}