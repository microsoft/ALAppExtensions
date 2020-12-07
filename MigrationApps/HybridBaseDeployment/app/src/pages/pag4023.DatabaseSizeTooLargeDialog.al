page 4023 "Database Size Too Large Dialog"
{
    Caption = 'Database Size Too Large';
    PageType = ConfirmationDialog;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Hybrid Company";
    InstructionalText = 'The maximum replicated data size of 30 GB has been exceeded. If you have selected multiple companies, deselect companies to reduce the size of the migrated company data. Once the migration process is complete for companies selected, you can select additional companies to migrate.';

    layout
    {
        area(Content)
        {
            field(MigrationDocumentationTxt; MigrationDocumentationTxt)
            {
                ApplicationArea = Basic, Suite;
                ShowCaption = false;
                trigger OnDrillDown()
                begin
                    Hyperlink(DocumentationURLTxt);
                end;
            }

            field(ConfirmMessage; ConfirmMsg)
            {
                ApplicationArea = Basic, Suite;
                ShowCaption = false;
            }
        }
    }

    actions
    {
    }

    var
        DocumentationURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2013440&clcid=0x409', Locked = true;
        MigrationDocumentationTxt: Label 'Cloud Migration Documentation';
        ConfirmMsg: Label 'Do you want to continue?';
}