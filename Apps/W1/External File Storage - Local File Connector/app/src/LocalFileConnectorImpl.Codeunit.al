// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

using System.Text;
using System.Utilities;
using System.Azure.Storage;
using System.Azure.Storage.Files;
using System.IO;
using System;

codeunit 4820 "Local File Connector Impl." implements "External File Storage Connector"
{
    Access = Internal;
    Permissions = tabledata "Local File Account" = rimd;

    var
        ConnectorDescriptionTxt: Label 'Use Local File to store and retrieve files from the server file system.';
        NotRegisteredAccountErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';

    /// <summary>
    /// Gets a List of Files stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="Files">A list with all files stored in the path.</param>
    procedure ListFiles(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var FileAccountContent: Record "File Account Content" temporary)
    var
        LocalFileAccount: Record "Local File Account";
        LocalFile: Record File;
    begin
        LocalFileAccount.Get(AccountId);
        FilePaginationData.SetEndOfListing(true);
        SetLocalFileFilters(AccountId, Path, LocalFile, true);
        if not LocalFile.FindSet() then
            exit;

        repeat
            FileAccountContent.Init();
            FileAccountContent.Name := LocalFile.Name;
            FileAccountContent.Type := FileAccountContent.Type::"File";
            FileAccountContent."Parent Directory" := CopyStr(GetParentPath(LocalFileAccount, LocalFile.Path), 1, MaxStrLen(FileAccountContent."Parent Directory"));
            FileAccountContent.Insert();
        until LocalFile.Next() = 0;
    end;

    /// <summary>
    /// Gets a file from the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read to.</param>
    procedure GetFile(AccountId: Guid; Path: Text; Stream: InStream)
    var
        LocalFile: File;
        LocalPath: Text;
        TempBlobOutStream: OutStream;
        LocalFileInStream: InStream;
    begin
        Clear(TempBlob);
        LocalPath := GetLocalPath(AccountId, Path);
        LocalFile.Open(LocalPath);
        LocalFile.CreateInStream(LocalFileInStream);
        TempBlob.CreateOutStream(TempBlobOutStream);
        CopyStream(TempBlobOutStream, LocalFileInStream);
        LocalFile.Close();

        TempBlob.CreateInStream(Stream);
    end;

    /// <summary>
    /// Create a file in the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read from.</param>
    procedure CreateFile(AccountId: Guid; Path: Text; Stream: InStream)
    var
        LocalFile: File;
        LocalPath: Text;
        LocalFileStream: OutStream;
    begin
        LocalPath := GetLocalPath(AccountId, Path);
        LocalFile.Create(LocalPath);
        LocalFile.CreateOutStream(LocalFileStream);
        CopyStream(LocalFileStream, Stream);
    end;

    /// <summary>
    /// Copies as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure CopyFile(AccountId: Guid; SourcePath: Text; TargetPath: Text)
    var
        LocalSourcePath, LocalTargetPath : Text;
    begin
        LocalSourcePath := GetLocalPath(AccountId, SourcePath);
        LocalTargetPath := GetLocalPath(AccountId, TargetPath);

        File.Copy(LocalSourcePath, LocalTargetPath);
    end;

    /// <summary>
    /// Move as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure MoveFile(AccountId: Guid; SourcePath: Text; TargetPath: Text)
    var
        LocalSourcePath, LocalTargetPath : Text;
    begin
        LocalSourcePath := GetLocalPath(AccountId, SourcePath);
        LocalTargetPath := GetLocalPath(AccountId, TargetPath);

        File.Rename(LocalSourcePath, LocalTargetPath);
    end;

    /// <summary>
    /// Checks if a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <returns>Returns true if the file exists</returns>
    procedure FileExists(AccountId: Guid; Path: Text): Boolean
    var
        LocalPath: Text;
    begin
        LocalPath := GetLocalPath(AccountId, Path);

        exit(File.Exists(LocalPath));
    end;

    /// <summary>
    /// Deletes a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    procedure DeleteFile(AccountId: Guid; Path: Text)
    var
        LocalPath: Text;
    begin
        LocalPath := GetLocalPath(AccountId, Path);

        File.Erase(LocalPath);
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
        LocalFileAccount: Record "Local File Account";
        LocalFile: Record File;
    begin
        FilePaginationData.SetEndOfListing(true);
        LocalFileAccount.Get(AccountId);
        SetLocalFileFilters(AccountId, Path, LocalFile, false);
        if not LocalFile.FindSet() then
            exit;

        repeat
            FileAccountContent.Init();
            FileAccountContent.Name := LocalFile.Name;
            FileAccountContent.Type := FileAccountContent.Type::Directory;
            FileAccountContent."Parent Directory" := CopyStr(GetParentPath(LocalFileAccount, LocalFile.Path), 1, MaxStrLen(FileAccountContent."Parent Directory"));
            if not (LocalFile.Name in ['..', '.']) then
                FileAccountContent.Insert();
        until LocalFile.Next() = 0;
    end;

    /// <summary>
    /// Creates a directory on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure CreateDirectory(AccountId: Guid; Path: Text)
    var
        LocalPath: Text;
    begin
        LocalPath := GetLocalPath(AccountId, Path);
        ServerDirectoryHelper.CreateDirectory(LocalPath);
    end;

    /// <summary>
    /// Checks if a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <returns>Returns true if the directory exists</returns>
    procedure DirectoryExists(AccountId: Guid; Path: Text): Boolean
    var
        LocalPath: Text;
    begin
        if Path = '' then
            exit(true);

        LocalPath := GetLocalPath(AccountId, Path);
        exit(ServerDirectoryHelper.Exists(LocalPath));
    end;

    /// <summary>
    /// Deletes a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure DeleteDirectory(AccountId: Guid; Path: Text)
    var
        LocalPath: Text;
    begin
        if Path = '' then
            exit;

        LocalPath := GetLocalPath(AccountId, Path);
        ServerDirectoryHelper.Delete(LocalPath);
    end;

    /// <summary>
    /// Gets the registered accounts for the File Share connector.
    /// </summary>
    /// <param name="Accounts">Out parameter holding all the registered accounts for the File Share connector.</param>
    procedure GetAccounts(var TempAccounts: Record "File Account" temporary)
    var
        Account: Record "Local File Account";
    begin
        if not Account.FindSet() then
            exit;

        repeat
            TempAccounts."Account Id" := Account.Id;
            TempAccounts.Name := Account.Name;
            TempAccounts.Connector := Enum::"Ext. File Storage Connector"::"Local File";
            TempAccounts.Insert();
        until Account.Next() = 0;
    end;

    /// <summary>
    /// Shows accounts information.
    /// </summary>
    /// <param name="AccountId">The ID of the account to show.</param>
    procedure ShowAccountInformation(AccountId: Guid)
    var
        FileShareAccountLocal: Record "Local File Account";
    begin
        if not FileShareAccountLocal.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        FileShareAccountLocal.SetRecFilter();
        Page.Run(Page::"Local File Account", FileShareAccountLocal);
    end;

    /// <summary>
    /// Register an file account for the File Share connector.
    /// </summary>
    /// <param name="TempAccount">Out parameter holding details of the registered account.</param>
    /// <returns>True if the registration was successful; false - otherwise.</returns>
    procedure RegisterAccount(var TempAccount: Record "File Account" temporary): Boolean
    var
        FileShareAccountWizard: Page "Local File Account Wizard";
    begin
        FileShareAccountWizard.RunModal();

        exit(FileShareAccountWizard.GetAccount(TempAccount));
    end;

    /// <summary>
    /// Deletes an file account for the File Share connector.
    /// </summary>
    /// <param name="AccountId">The ID of the File Share account</param>
    /// <returns>True if an account was deleted.</returns>
    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        FileShareAccountLocal: Record "Local File Account";
    begin
        if FileShareAccountLocal.Get(AccountId) then
            exit(FileShareAccountLocal.Delete());

        exit(false);
    end;

    /// <summary>
    /// Gets a description of the File Share connector.
    /// </summary>
    /// <returns>A short description of the File Share connector.</returns>
    procedure GetDescription(): Text[250]
    begin
        exit(ConnectorDescriptionTxt);
    end;

    /// <summary>
    /// Gets the File Share connector logo.
    /// </summary>
    /// <returns>A base64-formatted image to be used as logo.</returns>
    procedure GetLogoAsBase64(): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        Stream: InStream;
    begin
        NavApp.GetResource('connector-logo.png', Stream);
        exit(Base64Convert.ToBase64(Stream));
    end;

    internal procedure IsAccountValid(var Account: Record "Local File Account" temporary): Boolean
    begin
        if Account.Name = '' then
            exit(false);

        if Account."Base Path" = '' then
            exit(false);

        exit(true);
    end;

    [NonDebuggable]
    internal procedure CreateAccount(var AccountToCopy: Record "Local File Account"; var FileAccount: Record "File Account")
    var
        NewFileShareAccount: Record "Local File Account";
    begin
        NewFileShareAccount.TransferFields(AccountToCopy);
        NewFileShareAccount.Id := CreateGuid();
        NewFileShareAccount.Insert();

        FileAccount."Account Id" := NewFileShareAccount.Id;
        FileAccount.Name := NewFileShareAccount.Name;
        FileAccount.Connector := Enum::"Ext. File Storage Connector"::"Local File";
    end;

    local procedure CheckPath(var Path: Text)
    begin
        if (Path <> '') and not Path.EndsWith(PathSeparator()) then
            Path += PathSeparator();
    end;

    local procedure SetLocalFileFilters(var AccountId: Guid; var Path: Text; var LocalFile: Record File; Files: Boolean)
    var
        LocalPath: Text;
    begin
        CheckPath(Path);
        LocalPath := GetLocalPath(AccountId, Path);

        LocalFile.SetRange(Path, LocalPath);
        LocalFile.SetRange("Is a file", Files);
    end;

    local procedure PathSeparator(): Text
    begin
        exit('/');
    end;

    local procedure GetLocalPath(AccountId: Guid; Path: Text) LocalPath: Text
    var
        LocalFileAccount: Record "Local File Account";
    begin
        LocalFileAccount.Get(AccountId);
        LocalFileAccount.TestField("Base Path");

        LocalPath := LocalFileAccount."Base Path";
        if not LocalPath.EndsWith('\') then
            LocalPath += '\';

        LocalPath += Path;

        exit(ConvertPath(LocalPath));
    end;

    local procedure ConvertPath(Path: Text): Text
    begin
        exit(Path.Replace(PathSeparator(), '\'));
    end;

    local procedure GetParentPath(LocalFileAccount: Record "Local File Account"; Path: Text): Text
    var
        LocalPath: Text;
    begin
        LocalPath := Path;
        if Path.StartsWith(LocalFileAccount."Base Path".ToUpper()) then
            LocalPath := Path.Substring(StrLen(LocalFileAccount."Base Path"));

        if LocalPath.StartsWith('\') then
            LocalPath := LocalPath.Substring(2);

        if LocalPath = '\' then
            LocalPath := '';

        exit(LocalPath.Replace('\', PathSeparator()));
    end;

    var
        TempBlob: Codeunit "Temp Blob";
        ServerDirectoryHelper: DotNet Directory;
}