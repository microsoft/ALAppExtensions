codeunit 70005 "File System Impl."
{
    var
        IFileConnector: Interface "File Connector";
        CurrFileAccount: Record "File Account";
        Initialized: Boolean;

    internal procedure Initialize(Scenario: Enum "File Scenario")
    var
        FileAccount: Record "File Account";
        FileScenario: Codeunit "File Scenario";
        NoFileAccountFoundErr: Label 'No defaut file account defined.';
    begin
        if not FileScenario.GetFileAccount(Scenario, FileAccount) then
            Error(NoFileAccountFoundErr);

        Initialize(FileAccount);
    end;

    internal procedure Initialize(FileAccount: Record "File Account")
    begin
        CurrFileAccount := FileAccount;
        IFileConnector := FileAccount.Connector;
        Initialized := true;
    end;

    internal procedure ListFiles(Path: Text; var FileAccountContent: Record "File Account Content" temporary)
    begin
        CheckInitialization();
        IFileConnector.ListFiles(Path, CurrFileAccount."Account Id", FileAccountContent);
    end;

    internal procedure GetFile(Path: Text; Stream: InStream)
    begin
        CheckInitialization();
        IFileConnector.GetFile(Path, CurrFileAccount."Account Id", Stream);
    end;

    internal procedure SetFile(Path: Text; Stream: InStream)
    begin
        CheckInitialization();
        IFileConnector.SetFile(Path, CurrFileAccount."Account Id", Stream);
    end;

    internal procedure FileExists(Path: Text): Boolean
    begin
        CheckInitialization();
        exit(IFileConnector.FileExists(Path, CurrFileAccount."Account Id"));
    end;

    internal procedure DeleteFile(Path: Text)
    begin
        CheckInitialization();
        IFileConnector.DeleteFile(Path, CurrFileAccount."Account Id");
    end;

    internal procedure ListDirectories(Path: Text; var FileAccountContent: Record "File Account Content" temporary)
    begin
        CheckInitialization();
        IFileConnector.ListDirectories(Path, CurrFileAccount."Account Id", FileAccountContent);
    end;

    internal procedure CreateDirectory(Path: Text)
    begin
        CheckInitialization();
        IFileConnector.CreateDirectory(Path, CurrFileAccount."Account Id");
    end;

    internal procedure DirectoryExists(Path: Text): Boolean
    begin
        CheckInitialization();
        exit(IFileConnector.DirectoryExists(Path, CurrFileAccount."Account Id"));
    end;

    internal procedure PathSeparator(): Text
    begin
        CheckInitialization();
        exit(IFileConnector.PathSeparator());
    end;

    internal procedure CombinePath(Path: Text; ChildPath: Text): Text
    begin
        if Path = '' then
            exit(ChildPath);

        if not Path.EndsWith(PathSeparator()) then
            Path += PathSeparator();

        exit(Path + ChildPath);
    end;

    internal procedure GetParentPath(Path: Text) ParentPath: Text
    begin
        if (Path.TrimEnd(PathSeparator()).Contains(PathSeparator())) then
            ParentPath := Path.TrimEnd(PathSeparator()).Substring(1, Path.LastIndexOf(PathSeparator()));
    end;

    internal procedure SelectFolderUI(Path: Text): Text
    var
        FileAccountContent: Record "File Account Content";
        FileAccountBrowser: Page "File Account Browser";
    begin
        FileAccountBrowser.SetFileAcconut(CurrFileAccount);
        FileAccountBrowser.EnableDirectoryLookupMode(Path);
        if FileAccountBrowser.RunModal() <> Action::LookupOK then
            exit('');

        FileAccountBrowser.GetRecord(FileAccountContent);
        if FileAccountContent.Type <> FileAccountContent.Type::Directory then
            exit('');

        exit(CombinePath(FileAccountContent."Parent Directory", FileAccountContent.Name));
    end;

    internal procedure SelectFileUI(Path: Text; FileFilter: Text): Text
    var
        FileAccountContent: Record "File Account Content";
        FileAccountBrowser: Page "File Account Browser";
    begin
        FileAccountBrowser.SetFileAcconut(CurrFileAccount);
        FileAccountBrowser.EnableFileLookupMode(Path, FileFilter);
        if FileAccountBrowser.RunModal() <> Action::LookupOK then
            exit('');

        FileAccountBrowser.GetRecord(FileAccountContent);
        if FileAccountContent.Type <> FileAccountContent.Type::File then
            exit('');

        exit(CombinePath(FileAccountContent."Parent Directory", FileAccountContent.Name));
    end;

    internal procedure SaveFileUI(Path: Text; FileExtension: Text): Text
    var
        FileAccountContent: Record "File Account Content";
        FileAccountBrowser: Page "File Account Browser";
        FileName, FileNameWithExtenion : Text;
        PleaseProvideFileExtensionErr: Label 'Please provide a valid file extension.';
        FileNameTok: Label '%1.%2', Locked = true;
    begin
        if FileExtension = '' then
            Error(PleaseProvideFileExtensionErr);

        FileAccountBrowser.SetFileAcconut(CurrFileAccount);
        FileAccountBrowser.EnableSaveFileLookupMode(Path, FileExtension);
        if FileAccountBrowser.RunModal() <> Action::LookupOK then
            exit('');

        FileName := FileAccountBrowser.GetFileName();
        if FileName = '' then
            exit('');

        FileNameWithExtenion := StrSubstNo(FileNameTok, FileName, FileExtension);
        exit(CombinePath(FileAccountBrowser.GetCurrentDirectory(), FileNameWithExtenion));
    end;

    local procedure CheckInitialization()
    var
        NotInitializedErr: Label 'Please call Initalize() first.';
    begin
        if Initialized then
            exit;

        Error(NotInitializedErr);
    end;
}