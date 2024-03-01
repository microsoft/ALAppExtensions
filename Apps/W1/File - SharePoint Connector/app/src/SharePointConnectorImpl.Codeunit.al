// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

using System.Integration.Sharepoint;
using System.Utilities;

codeunit 80300 "SharePoint Connector Impl." implements "File System Connector"
{
    Access = Internal;
    Permissions = tabledata "SharePoint Account" = rimd;

    var
        ConnectorDescriptionTxt: Label 'Use SharePoint to store and retrieve files.';
        NotRegisteredAccountErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';
        ConnectorBase64LogoTxt: Label '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', Locked = true;
        MarkerFileNameTok: Label 'BusinessCentral.FileSystem.txt', Locked = true;
        NotFoundTok: Label '404', Locked = true;

    /// <summary>
    /// Gets a List of Files stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="Files">A list with all files stored in the path.</param>
    procedure ListFiles(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var FileAccountContent: Record "File Account Content" temporary)
    var
        SharePointFile: Record "SharePoint File";
        SharePointClient: Codeunit "SharePoint Client";
        OrginalPath: Text;
    begin
        OrginalPath := Path;
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if not SharePointClient.GetFolderFilesByServerRelativeUrl(Path, SharePointFile) then
            ShowError(SharePointClient);

        FilePaginationData.SetEndOfListing(true);

        if not SharePointFile.FindSet() then
            exit;

        repeat
            FileAccountContent.Init();
            FileAccountContent.Name := SharePointFile.Name;
            FileAccountContent.Type := FileAccountContent.Type::"File";
            FileAccountContent."Parent Directory" := OrginalPath;
            FileAccountContent.Insert();
        until SharePointFile.Next() = 0;
    end;

    /// <summary>
    /// Gets a file from the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read to.</param>
    procedure GetFile(AccountId: Guid; Path: Text; Stream: InStream)
    var
        SharePointFile: Record "SharePoint File";
        SharePointClient: Codeunit "SharePoint Client";
        TempBlob, TempBlob2 : Codeunit "Temp Blob";
        Content: HttpContent;
        TempBlobStream: InStream;
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);

        TempBlob.CreateInStream(Stream);
        if not SharePointClient.DownloadFileContentByServerRelativeUrl(Path, TempBlobStream) then
            ShowError(SharePointClient);

        // Platform fix: For some reason the Stream from DownloadFileContentByServerRelativeUrl dies after leaving the interface
        Content.WriteFrom(TempBlobStream);
        Content.ReadAs(Stream);
    end;

    /// <summary>
    /// Create a file in the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read from.</param>
    procedure CreateFile(AccountId: Guid; Path: Text; Stream: InStream)
    var
        SharePointFile: Record "SharePoint File";
        SharePointClient: Codeunit "SharePoint Client";
        ParentPath, FileName : Text;
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        SplitPath(Path, ParentPath, FileName);
        if SharePointClient.AddFileToFolder(ParentPath, FileName, Stream, SharePointFile, false) then
            exit;

        ShowError(SharePointClient);
    end;

    /// <summary>
    /// Copies as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure CopyFile(AccountId: Guid; SourcePath: Text; TargetPath: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        Stream: InStream;
    begin
        TempBlob.CreateInStream(Stream);

        GetFile(AccountId, SourcePath, Stream);
        CreateFile(AccountId, TargetPath, Stream);
    end;

    /// <summary>
    /// Move as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure MoveFile(AccountId: Guid; SourcePath: Text; TargetPath: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        Stream: InStream;
    begin
        TempBlob.CreateInStream(Stream);

        GetFile(AccountId, SourcePath, Stream);
        CreateFile(AccountId, TargetPath, Stream);
        DeleteFile(AccountId, SourcePath);
    end;

    /// <summary>
    /// Checks if a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <returns>Returns true if the file exists</returns>
    procedure FileExists(AccountId: Guid; Path: Text): Boolean
    var
        SharePointFile: Record "SharePoint File";
        SharePointClient: Codeunit "SharePoint Client";
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if not SharePointClient.GetFolderFilesByServerRelativeUrl(GetParentPath(Path), SharePointFile) then
            ShowError(SharePointClient);

        SharePointFile.SetRange(Name, GetFileName(Path));
        exit(not SharePointFile.IsEmpty());
    end;

    /// <summary>
    /// Deletes a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    procedure DeleteFile(AccountId: Guid; Path: Text)
    var
        SharePointClient: Codeunit "SharePoint Client";
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if SharePointClient.DeleteFileByServerRelativeUrl(Path) then
            exit;

        ShowError(SharePointClient);
    end;

    /// <summary>
    /// Gets a List of Directories stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="Files">A list with all directories stored in the path.</param>
    procedure ListDirectories(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var FileAccountContent: Record "File Account Content" temporary)
    var
        SharePointFolder: Record "SharePoint Folder";
        SharePointClient: Codeunit "SharePoint Client";
        OrginalPath: Text;
    begin
        OrginalPath := Path;
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if not SharePointClient.GetSubFoldersByServerRelativeUrl(Path, SharePointFolder) then
            ShowError(SharePointClient);

        FilePaginationData.SetEndOfListing(true);

        if not SharePointFolder.FindSet() then
            exit;

        repeat
            FileAccountContent.Init();
            FileAccountContent.Name := SharePointFolder.Name;
            FileAccountContent.Type := FileAccountContent.Type::Directory;
            FileAccountContent."Parent Directory" := OrginalPath;
            FileAccountContent.Insert();
        until SharePointFolder.Next() = 0;
    end;

    /// <summary>
    /// Creates a directory on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure CreateDirectory(AccountId: Guid; Path: Text)
    var
        SharePointFolder: Record "SharePoint Folder";
        SharePointClient: Codeunit "SharePoint Client";
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if SharePointClient.CreateFolder(Path, SharePointFolder) then
            exit;

        ShowError(SharePointClient);
    end;

    /// <summary>
    /// Checks if a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <returns>Returns true if the directory exists</returns>
    procedure DirectoryExists(AccountId: Guid; Path: Text): Boolean
    var
        SharePointFolder: Record "SharePoint Folder";
        SharePointClient: Codeunit "SharePoint Client";
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if SharePointClient.GetSubFoldersByServerRelativeUrl(Path, SharePointFolder) then
            exit;

        ShowError(SharePointClient);
    end;

    /// <summary>
    /// Deletes a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure DeleteDirectory(AccountId: Guid; Path: Text)
    var
        SharePointClient: Codeunit "SharePoint Client";
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if SharePointClient.DeleteFolderByServerRelativeUrl(Path) then
            exit;

        ShowError(SharePointClient);
    end;

    /// <summary>
    /// Gets the registered accounts for the SharePoint connector.
    /// </summary>
    /// <param name="Accounts">Out parameter holding all the registered accounts for the SharePoint connector.</param>
    procedure GetAccounts(var Accounts: Record "File Account")
    var
        Account: Record "SharePoint Account";
    begin
        if not Account.FindSet() then
            exit;

        repeat
            Accounts."Account Id" := Account.Id;
            Accounts.Name := Account.Name;
            Accounts.Connector := Enum::"File System Connector"::"SharePoint";
            Accounts.Insert();
        until Account.Next() = 0;
    end;

    /// <summary>
    /// Shows accounts information.
    /// </summary>
    /// <param name="AccountId">The ID of the account to show.</param>
    procedure ShowAccountInformation(AccountId: Guid)
    var
        FileShareAccountLocal: Record "SharePoint Account";
    begin
        if not FileShareAccountLocal.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        FileShareAccountLocal.SetRecFilter();
        Page.Run(Page::"SharePoint Account", FileShareAccountLocal);
    end;

    /// <summary>
    /// Register an file account for the SharePoint connector.
    /// </summary>
    /// <param name="Account">Out parameter holding details of the registered account.</param>
    /// <returns>True if the registration was successful; false - otherwise.</returns>
    procedure RegisterAccount(var Account: Record "File Account"): Boolean
    var
        FileShareAccountWizard: Page "SharePoint Account Wizard";
    begin
        FileShareAccountWizard.RunModal();

        exit(FileShareAccountWizard.GetAccount(Account));
    end;

    /// <summary>
    /// Deletes an file account for the SharePoint connector.
    /// </summary>
    /// <param name="AccountId">The ID of the SharePoint account</param>
    /// <returns>True if an account was deleted.</returns>
    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        FileShareAccountLocal: Record "SharePoint Account";
    begin
        if FileShareAccountLocal.Get(AccountId) then
            exit(FileShareAccountLocal.Delete());

        exit(false);
    end;

    /// <summary>
    /// Gets a description of the SharePoint connector.
    /// </summary>
    /// <returns>A short description of the SharePoint connector.</returns>
    procedure GetDescription(): Text[250]
    begin
        exit(ConnectorDescriptionTxt);
    end;

    /// <summary>
    /// Gets the SharePoint connector logo.
    /// </summary>
    /// <returns>A base64-formatted image to be used as logo.</returns>
    procedure GetLogoAsBase64(): Text
    begin
        exit(ConnectorBase64LogoTxt);
    end;

    internal procedure IsAccountValid(var Account: Record "SharePoint Account" temporary): Boolean
    begin
        if Account.Name = '' then
            exit(false);

        if Account."Client Id" = '' then
            exit(false);

        if Account."Tenant Id" = '' then
            exit(false);

        if Account."SharePoint Url" = '' then
            exit(false);

        if Account."Base Relative Folder Path" = '' then
            exit(false);

        exit(true);
    end;

    [NonDebuggable]
    internal procedure CreateAccount(var AccountToCopy: Record "SharePoint Account"; Password: Text; var FileAccount: Record "File Account")
    var
        NewFileShareAccount: Record "SharePoint Account";
    begin
        NewFileShareAccount.TransferFields(AccountToCopy);

        NewFileShareAccount.Id := CreateGuid();
        NewFileShareAccount.SetClientSecret(Password);

        NewFileShareAccount.Insert();

        FileAccount."Account Id" := NewFileShareAccount.Id;
        FileAccount.Name := NewFileShareAccount.Name;
        FileAccount.Connector := Enum::"File System Connector"::"SharePoint";
    end;

    local procedure InitSharePointClient(var AccountId: Guid; var SharePointClient: Codeunit "SharePoint Client")
    var
        FileShareAccount: Record "SharePoint Account";
        SharePointAuth: Codeunit "SharePoint Auth.";
        SharePointAuthorization: Interface "SharePoint Authorization";
        Scopes: List of [Text];
    begin
        FileShareAccount.Get(AccountId);
        Scopes.Add('00000003-0000-0ff1-ce00-000000000000/.default');
        SharePointAuthorization := SharePointAuth.CreateAuthorizationCode(FileShareAccount."Tenant Id", FileShareAccount."Client Id", FileShareAccount.GetClientSecret(FileShareAccount."Client Secret Key"), Scopes);
        SharePointClient.Initialize(FileShareAccount."SharePoint Url", SharePointAuthorization);
    end;

    local procedure PathSeparator(): Text
    begin
        exit('/');
    end;

    local procedure ShowError(var SharePointClient: Codeunit "SharePoint Client")
    var
        ErrorTok: Label 'An error occured.\%1';
    begin
        Error(ErrorTok, SharePointClient.GetDiagnostics().GetErrorMessage());
    end;

    local procedure GetParentPath(Path: Text) ParentPath: Text
    begin
        if (Path.TrimEnd(PathSeparator()).Contains(PathSeparator())) then
            ParentPath := Path.TrimEnd(PathSeparator()).Substring(1, Path.LastIndexOf(PathSeparator()));
    end;

    local procedure GetFileName(Path: Text) FileName: Text
    begin
        if (Path.TrimEnd(PathSeparator()).Contains(PathSeparator())) then
            FileName := Path.TrimEnd(PathSeparator()).Substring(Path.LastIndexOf(PathSeparator()) + 1);
    end;

    local procedure InitPath(AccountId: Guid; var Path: Text)
    var
        FileShareAccount: Record "SharePoint Account";
    begin
        FileShareAccount.Get(AccountId);
        Path := CombinePath(FileShareAccount."Base Relative Folder Path", Path);
    end;

    local procedure CombinePath(Parent: Text; Child: Text): Text
    begin
        if Parent = '' then
            exit(Child);

        if Child = '' then
            exit(Parent);

        if not Parent.EndsWith(PathSeparator()) then
            Parent += PathSeparator();

        exit(Parent + Child);
    end;

    local procedure SplitPath(Path: Text; var ParentPath: Text; var FileName: Text)
    begin
        ParentPath := Path.TrimEnd(PathSeparator()).Substring(1, Path.LastIndexOf(PathSeparator()));
        FileName := Path.TrimEnd(PathSeparator()).Substring(Path.LastIndexOf(PathSeparator()) + 1);
    end;
}