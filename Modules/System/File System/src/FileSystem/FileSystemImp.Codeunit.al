// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

codeunit 70005 "File System Impl."
{
    var
        IFileConnector: Interface "File System Connector";
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

    internal procedure ListFiles(Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var FileAccountContent: Record "File Account Content" temporary)
    begin
        CheckInitialization();
        IFileConnector.ListFiles(CurrFileAccount."Account Id", Path, FilePaginationData, FileAccountContent);
    end;

    internal procedure GetFile(Path: Text; Stream: InStream)
    begin
        CheckInitialization();
        IFileConnector.GetFile(CurrFileAccount."Account Id", Path, Stream);
    end;

    internal procedure SetFile(Path: Text; Stream: InStream)
    begin
        CheckInitialization();
        IFileConnector.SetFile(CurrFileAccount."Account Id", Path, Stream);
    end;


    internal procedure CopyFile(SourcePath: Text; TargetPath: Text)
    begin
        CheckInitialization();
        IFileConnector.CopyFile(CurrFileAccount."Account Id", SourcePath, TargetPath);
    end;

    internal procedure MoveFile(SourcePath: Text; TargetPath: Text)
    begin
        CheckInitialization();
        IFileConnector.MoveFile(CurrFileAccount."Account Id", SourcePath, TargetPath);
    end;

    internal procedure FileExists(Path: Text): Boolean
    begin
        CheckInitialization();
        exit(IFileConnector.FileExists(CurrFileAccount."Account Id", Path));
    end;

    internal procedure DeleteFile(Path: Text)
    begin
        CheckInitialization();
        IFileConnector.DeleteFile(CurrFileAccount."Account Id", Path);
    end;

    internal procedure ListDirectories(Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var FileAccountContent: Record "File Account Content" temporary)
    begin
        CheckInitialization();
        IFileConnector.ListDirectories(CurrFileAccount."Account Id", Path, FilePaginationData, FileAccountContent);
    end;

    internal procedure CreateDirectory(Path: Text)
    begin
        CheckInitialization();
        IFileConnector.CreateDirectory(CurrFileAccount."Account Id", Path);
    end;

    internal procedure DirectoryExists(Path: Text): Boolean
    begin
        CheckInitialization();
        exit(IFileConnector.DirectoryExists(CurrFileAccount."Account Id", Path));
    end;

    internal procedure DeleteDirectory(Path: Text)
    begin
        CheckInitialization();
        IFileConnector.DeleteDirectory(CurrFileAccount."Account Id", Path);
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

    internal procedure SelectFolderUI(Path: Text; DialogTitle: Text): Text
    var
        FileAccountContent: Record "File Account Content";
        FileAccountBrowser: Page "File Account Browser";
    begin
        CheckInitialization();

        FileAccountBrowser.SetPageCaption(DialogTitle);
        FileAccountBrowser.SetFileAcconut(CurrFileAccount);
        FileAccountBrowser.EnableDirectoryLookupMode(Path);
        if FileAccountBrowser.RunModal() <> Action::LookupOK then
            exit('');

        FileAccountBrowser.GetRecord(FileAccountContent);
        if FileAccountContent.Type <> FileAccountContent.Type::Directory then
            exit('');

        exit(CombinePath(FileAccountContent."Parent Directory", FileAccountContent.Name));
    end;

    internal procedure SelectFileUI(Path: Text; FileFilter: Text; DialogTitle: Text): Text
    var
        FileAccountContent: Record "File Account Content";
        FileAccountBrowser: Page "File Account Browser";
    begin
        CheckInitialization();

        FileAccountBrowser.SetPageCaption(DialogTitle);
        FileAccountBrowser.SetFileAcconut(CurrFileAccount);
        FileAccountBrowser.EnableFileLookupMode(Path, FileFilter);
        if FileAccountBrowser.RunModal() <> Action::LookupOK then
            exit('');

        FileAccountBrowser.GetRecord(FileAccountContent);
        if FileAccountContent.Type <> FileAccountContent.Type::File then
            exit('');

        exit(CombinePath(FileAccountContent."Parent Directory", FileAccountContent.Name));
    end;

    internal procedure SaveFileUI(Path: Text; FileExtension: Text; DialogTitle: Text): Text
    var
        FileAccountContent: Record "File Account Content";
        FileAccountBrowser: Page "File Account Browser";
        FileName, FileNameWithExtenion : Text;
        PleaseProvideFileExtensionErr: Label 'Please provide a valid file extension.';
        FileNameTok: Label '%1.%2', Locked = true;
    begin
        CheckInitialization();

        if FileExtension = '' then
            Error(PleaseProvideFileExtensionErr);

        FileAccountBrowser.SetPageCaption(DialogTitle);
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

    internal procedure BrowseAccount()
    var
        FileAccountImpl: Codeunit "File Account Impl.";
    begin
        CheckInitialization();
        FileAccountImpl.BrowseAccount(CurrFileAccount);
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