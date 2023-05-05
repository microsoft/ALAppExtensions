codeunit 70004 "File System"
{
    var
        FileSystemImpl: Codeunit "File System Impl.";

    procedure Initialize(Scenario: Enum "File Scenario")
    begin
        FileSystemImpl.Initialize(Scenario);
    end;

    procedure Initialize(FileAccount: Record "File Account")
    begin
        FileSystemImpl.Initialize(FileAccount);
    end;

    [TryFunction]
    procedure ListFiles(Path: Text; var FileAccountContent: Record "File Account Content" temporary)
    begin
        FileSystemImpl.ListFiles(Path, FileAccountContent);
    end;

    [TryFunction]
    procedure GetFile(Path: Text; Stream: InStream)
    begin
        FileSystemImpl.GetFile(Path, Stream);
    end;

    [TryFunction]
    procedure SetFile(Path: Text; Stream: InStream)
    begin
        FileSystemImpl.SetFile(Path, Stream);
    end;

    procedure FileExists(Path: Text): Boolean
    begin
        exit(FileSystemImpl.FileExists(Path));
    end;

    [TryFunction]
    procedure DeleteFile(Path: Text)
    begin
        FileSystemImpl.DeleteFile(Path);
    end;

    [TryFunction]
    procedure ListDirectories(Path: Text; var FileAccountContent: Record "File Account Content" temporary)
    begin
        FileSystemImpl.ListDirectories(Path, FileAccountContent);
    end;

    [TryFunction]
    procedure CreateDirectory(Path: Text)
    begin
        FileSystemImpl.CreateDirectory(Path);
    end;

    procedure DirectoryExists(Path: Text): Boolean
    begin
        exit(FileSystemImpl.DirectoryExists(Path));
    end;

    procedure PathSeparator(): Text
    begin
        exit(FileSystemImpl.PathSeparator());
    end;

    procedure CombinePath(Path: Text; ChildPath: Text): Text
    begin
        Exit(FileSystemImpl.CombinePath(Path, ChildPath));
    end;

    procedure GetParentPath(Path: Text): Text
    begin
        exit(FileSystemImpl.GetParentPath(Path));
    end;

    procedure SelectFolderUI(Path: Text): Text
    begin
        exit(FileSystemImpl.SelectFolderUI(Path));
    end;

    procedure SelectFileUI(Path: Text; FileFilter: Text): Text
    begin
        exit(FileSystemImpl.SelectFileUI(Path, FileFilter));
    end;

    procedure SaveFileUI(Path: Text; FileExtension: Text): Text
    begin
        exit(FileSystemImpl.SaveFileUI(Path, FileExtension));
    end;
}