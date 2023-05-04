page 70005 "File Account Browser"
{
    Caption = 'File Account Browser';
    PageType = List;
    SourceTable = "File Account Content";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    DrillDown = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';

                    trigger OnDrillDown()
                    begin
                        if Rec.Type = Rec.Type::Directory then
                            BrowseFolder(Rec)
                        else
                            DownloadFile(Rec);
                    end;
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Up)
            {
                Caption = 'Up';
                ApplicationArea = All;
                Image = MoveUp;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = ParentFolderExists;

                trigger OnAction()
                var
                    Path: Text;
                begin
                    if CurrPath = '' then
                        exit;

                    if (CurrPath.TrimEnd(IFileConnector.PathSeparator()).Contains(IFileConnector.PathSeparator())) then
                        Path := CurrPath.TrimEnd(IFileConnector.PathSeparator()).Substring(1, CurrPath.LastIndexOf(IFileConnector.PathSeparator()));

                    BrowseFolder(Path);
                end;
            }
            action(Upload)
            {
                Caption = 'Upload';
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    UploadFile();
                    BrowseFolder(CurrPath);
                end;
            }
        }
    }

    var
        IFileConnector: Interface "File Connector";
        AccountId: Guid;
        CurrPath: Text;
        ParentFolderExists: Boolean;

    procedure BrowseFileAccount(FileAccount: Record "File Account")
    begin
        BrowseFileAccount(FileAccount, '');
    end;

    procedure BrowseFileAccount(FileAccount: Record "File Account"; Path: Text)
    begin
        AccountId := FileAccount."Account Id";
        IFileConnector := FileAccount.Connector;
        BrowseFolder('');
    end;

    local procedure BrowseFolder(var TempFileAccountContent: Record "File Account Content" temporary)
    var
        Path: Text;
    begin
        Path := CombinePath(TempFileAccountContent."Parent Directory", TempFileAccountContent.Name);
        BrowseFolder(Path);
    end;

    local procedure BrowseFolder(Path: Text)
    var
        Directiories: List of [Text];
        Files: List of [Text];
        Entry: Text;
    begin
        CurrPath := Path;
        ParentFolderExists := CurrPath <> '';
        Rec.DeleteAll();
        IFileConnector.ListDirectories(Path, AccountId, Rec);
        IFileConnector.ListFiles(Path, AccountId, Rec);
        IF Rec.FindFirst() then;
    end;

    local procedure CombinePath(ParentDirectory: Text; Name: Text): Text
    begin
        if ParentDirectory = '' then
            exit(Name);

        if not ParentDirectory.EndsWith(IFileConnector.PathSeparator()) then
            ParentDirectory += IFileConnector.PathSeparator();

        exit(ParentDirectory + Name);
    end;

    local procedure DownloadFile(var TempFileAccountContent: Record "File Account Content" temporary)
    var
        Stream: InStream;
    begin
        IFileConnector.GetFile(CombinePath(TempFileAccountContent."Parent Directory", TempFileAccountContent.Name), AccountId, Stream);
        DownloadFromStream(Stream, '', '', '', TempFileAccountContent.Name);
    end;

    local procedure UploadFile()
    var
        UploadDialogTxt: Label 'Upload File';
        FromFile: Text;
        Stream: InStream;
    begin
        if not UploadIntoStream(UploadDialogTxt, '', '', FromFile, Stream) then
            exit;

        IFileConnector.SetFile(CombinePath(CurrPath, FromFile), AccountId, Stream);
    end;
}
