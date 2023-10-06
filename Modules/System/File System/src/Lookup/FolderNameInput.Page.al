page 70006 "Folder Name Input"
{
    ApplicationArea = All;
    Caption = 'Create Folder...';
    PageType = StandardDialog;
    Extensible = false;

    layout
    {
        area(content)
        {
            field(FolderNameField; FolderName)
            {
                Caption = 'Folder Name';
            }
        }
    }

    var
        FolderName: Text;

    internal procedure GetFolderName(): Text
    begin
        exit(FolderName);
    end;
}
