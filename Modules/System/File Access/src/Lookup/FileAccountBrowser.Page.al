page 70005 "File Account Browser"
{
    Caption = 'File Account Browser';
    PageType = List;
    SourceTable = "File Account Content";
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;

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
                            if not IsInLookupMode then
                                DownloadFile(Rec);
                    end;
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.';
                }
            }

            group(SaveFileNameGroup)
            {
                Caption = '', Locked = true;
                ShowCaption = false;
                Visible = ShowFileName;

                field(SaveFileNameField; SaveFileName)
                {
                    Caption = 'Filename';
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

                    Path := FileSystem.GetParentPath(CurrPath);
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
                Visible = not IsInLookupMode;
                Enabled = not IsInLookupMode;

                trigger OnAction()
                begin
                    UploadFile();
                    BrowseFolder(CurrPath);
                end;
            }
        }
    }

    var
        FileSystem: Codeunit "File System";
        CurrPath, CurrFileFilter, SaveFileName : Text;
        ParentFolderExists, DoNotLoadFields, IsInLookupMode, ShowFileName : Boolean;

    internal procedure SetFileAcconut(FileAccount: Record "File Account")
    begin
        FileSystem.Initialize(FileAccount);
    end;

    internal procedure BrowseFileAccount(Path: Text)
    begin
        BrowseFolder('');
    end;

    internal procedure EnableFileLookupMode(Path: Text; FileFilter: Text)
    begin
        CurrFileFilter := FileFilter;
        ApplyFileFilter();
        EnableLookupMode();
        BrowseFolder(Path);
    end;

    internal procedure EnableDirectoryLookupMode(Path: Text)
    begin
        DoNotLoadFields := true;
        EnableLookupMode();
        BrowseFolder(Path);
    end;

    internal procedure EnableSaveFileLookupMode(Path: Text; FileExtension: Text)
    var
        FileFilterTok: Label '*.%1', Locked = true;
    begin
        ShowFileName := true;
        EnableLookupMode();
        BrowseFolder(Path);
        CurrFileFilter := StrSubstNo(FileFilterTok, FileExtension);
        ApplyFileFilter();
    end;

    internal procedure GetCurrentDirectory(): Text
    begin
        exit(CurrPath);
    end;

    internal procedure GetFileName(): Text
    begin
        exit(SaveFileName);
    end;

    local procedure EnableLookupMode()
    begin
        IsInLookupMode := true;
        CurrPage.LookupMode(true);
    end;

    local procedure BrowseFolder(var TempFileAccountContent: Record "File Account Content" temporary)
    var
        Path: Text;
    begin
        Path := FileSystem.CombinePath(TempFileAccountContent."Parent Directory", TempFileAccountContent.Name);
        BrowseFolder(Path);
    end;

    local procedure BrowseFolder(Path: Text)
    begin
        CurrPath := Path;
        ParentFolderExists := CurrPath <> '';
        Rec.DeleteAll();

        FileSystem.ListDirectories(Path, Rec);
        if not DoNotLoadFields then
            FileSystem.ListFiles(Path, Rec);

        ApplyFileFilter();
        if Rec.FindFirst() then;
    end;

    local procedure DownloadFile(var TempFileAccountContent: Record "File Account Content" temporary)
    var
        Stream: InStream;
    begin
        FileSystem.GetFile(FileSystem.CombinePath(TempFileAccountContent."Parent Directory", TempFileAccountContent.Name), Stream);
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

        FileSystem.SetFile(FileSystem.CombinePath(CurrPath, FromFile), Stream);
    end;

    local procedure ApplyFileFilter()
    var
        CurrFilterGroup: Integer;
    begin
        if CurrFileFilter = '' then
            exit;

        CurrFilterGroup := Rec.FilterGroup();
        Rec.FilterGroup(-1);
        Rec.SetRange(Type, Type::Directory);
        Rec.SetFilter(Name, CurrFileFilter);
        Rec.FilterGroup(CurrFilterGroup);
    end;
}
