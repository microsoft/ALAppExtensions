page 4023 "Database Size Too Large Dialog"
{
    Caption = 'Database Size Too Large';
    PageType = ConfirmationDialog;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Hybrid Company";

    layout
    {
        area(Content)
        {
            label(Control2)
            {
                ApplicationArea = Basic, Suite;
                CaptionClass = NotificationText;
                MultiLine = true;
                ShowCaption = false;
            }
            field(MigrationDocumentation; MigrationDocumentationTxt)
            {
                ApplicationArea = Basic, Suite;
                ShowCaption = false;
                trigger OnDrillDown()
                begin
                    Hyperlink(DocumentationURLTxt);
                end;
            }

            label(ConfirmMessage)
            {
                ApplicationArea = Basic, Suite;
                ShowCaption = false;
                CaptionClass = QuestionText;
                MultiLine = true;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        NotificationText := StrSubstNo(LargeDatabaseWarningMsg);
        QuestionText := ConfirmMsg;
    end;

    var
        DocumentationURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2013440&clcid=0x409', Locked = true;
        MigrationDocumentationTxt: Label 'Migrating On-Premises Data';
        ConfirmMsg: Label 'Do you want to continue?';
        LargeDatabaseWarningMsg: Label 'You are migrating a large amount of data. If your Business Central online storage exceeds the limits, some administrative tasks are disabled. We recommend that you consider reducing the amount of data that you migrate. Find tips about how to manage the data that you migrate here:', Comment = '%1 is the size limit in GB';
        NotificationText: Text;
        QuestionText: Text;
}
