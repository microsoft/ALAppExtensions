// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

using System.Utilities;
using System.Azure.Storage;
using System.Azure.Storage.Files;

codeunit 80200 "File Share Connector Impl." implements "External File Storage Connector"
{
    Access = Internal;
    Permissions = tabledata "File Share Account" = rimd;

    var
        ConnectorDescriptionTxt: Label 'Use Azure File Share to store and retrieve files.';
        NotRegisteredAccountErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';
        ConnectorBase64LogoTxt: Label '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', Locked = true;
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
        AFSDirectoryContent: Record "AFS Directory Content";
    begin
        GetDirectoryContent(AccountId, Path, FilePaginationData, AFSDirectoryContent);

        AFSDirectoryContent.SetRange("Parent Directory", Path);
        AFSDirectoryContent.SetRange("Resource Type", AFSDirectoryContent."Resource Type"::File);
        if not AFSDirectoryContent.FindSet() then
            exit;

        repeat
            FileAccountContent.Init();
            FileAccountContent.Name := AFSDirectoryContent.Name;
            FileAccountContent.Type := FileAccountContent.Type::"File";
            FileAccountContent."Parent Directory" := AFSDirectoryContent."Parent Directory";
            FileAccountContent.Insert();
        until AFSDirectoryContent.Next() = 0;
    end;

    /// <summary>
    /// Gets a file from the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read to.</param>
    procedure GetFile(AccountId: Guid; Path: Text; Stream: InStream)
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
    begin
        InitFileClient(AccountId, AFSFileClient);
        AFSOperationResponse := AFSFileClient.GetFileAsStream(Path, Stream);

        if AFSOperationResponse.IsSuccessful() then
            exit;

        Error(AFSOperationResponse.GetError());
    end;

    /// <summary>
    /// Create a file in the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read from.</param>
    procedure CreateFile(AccountId: Guid; Path: Text; Stream: InStream)
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
    begin
        InitFileClient(AccountId, AFSFileClient);

        AFSOperationResponse := AFSFileClient.CreateFile(Path, Stream);
        if not AFSOperationResponse.IsSuccessful() then
            Error(AFSOperationResponse.GetError());

        AFSOperationResponse := AFSFileClient.PutFileStream(Path, Stream);
        if not AFSOperationResponse.IsSuccessful() then
            Error(AFSOperationResponse.GetError());
    end;

    /// <summary>
    /// Copies as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure CopyFile(AccountId: Guid; SourcePath: Text; TargetPath: Text)
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
    begin
        InitFileClient(AccountId, AFSFileClient);
        AFSOperationResponse := AFSFileClient.CopyFile(TargetPath, SourcePath);

        if AFSOperationResponse.IsSuccessful() then
            exit;

        Error(AFSOperationResponse.GetError());
    end;

    /// <summary>
    /// Move as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure MoveFile(AccountId: Guid; SourcePath: Text; TargetPath: Text)
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
    begin
        InitFileClient(AccountId, AFSFileClient);
        AFSOperationResponse := AFSFileClient.RenameFile(TargetPath, SourcePath);
        if not AFSOperationResponse.IsSuccessful() then
            Error(AFSOperationResponse.GetError());
    end;

    /// <summary>
    /// Checks if a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <returns>Returns true if the file exists</returns>
    procedure FileExists(AccountId: Guid; Path: Text): Boolean
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSDirectoryContent: Record "AFS Directory Content";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
        TargetText: Text;
    begin
        if Path = '' then
            exit(false);

        InitFileClient(AccountId, AFSFileClient);
        AFSOptionalParameters.Range(0, 1);

        AFSOperationResponse := AFSFileClient.GetFileAsText(Path, TargetText, AFSOptionalParameters);
        if AFSOperationResponse.GetError().Contains(NotFoundTok) then
            exit(false)
        else
            Error(AFSOperationResponse.GetError());

        exit(true);
    end;

    /// <summary>
    /// Deletes a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    procedure DeleteFile(AccountId: Guid; Path: Text)
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
    begin
        InitFileClient(AccountId, AFSFileClient);
        AFSOperationResponse := AFSFileClient.DeleteFile(Path);

        if AFSOperationResponse.IsSuccessful() then
            exit;

        Error(AFSOperationResponse.GetError());
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
        AFSDirectoryContent: Record "AFS Directory Content";
    begin
        GetDirectoryContent(AccountId, Path, FilePaginationData, AFSDirectoryContent);

        AFSDirectoryContent.SetRange("Parent Directory", Path);
        AFSDirectoryContent.SetRange("Resource Type", AFSDirectoryContent."Resource Type"::Directory);
        if not AFSDirectoryContent.FindSet() then
            exit;

        repeat
            FileAccountContent.Init();
            FileAccountContent.Name := AFSDirectoryContent.Name;
            FileAccountContent.Type := FileAccountContent.Type::Directory;
            FileAccountContent."Parent Directory" := AFSDirectoryContent."Parent Directory";
            FileAccountContent.Insert();
        until AFSDirectoryContent.Next() = 0;
    end;

    /// <summary>
    /// Creates a directory on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure CreateDirectory(AccountId: Guid; Path: Text)
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        DirectoryAlreadyExistsErr: Label 'Directory already exists.';
    begin
        if DirectoryExists(AccountId, Path) then
            Error(DirectoryAlreadyExistsErr);

        InitFileClient(AccountId, AFSFileClient);
        AFSOperationResponse := AFSFileClient.CreateDirectory(Path);
        if not AFSOperationResponse.IsSuccessful() then
            Error(AFSOperationResponse.GetError());
    end;

    /// <summary>
    /// Checks if a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <returns>Returns true if the directory exists</returns>
    procedure DirectoryExists(AccountId: Guid; Path: Text): Boolean
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSDirectoryContent: Record "AFS Directory Content";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        if Path = '' then
            exit(true);

        InitFileClient(AccountId, AFSFileClient);
        AFSOptionalParameters.MaxResults(1);
        AFSOperationResponse := AFSFileClient.ListDirectory(Path, AFSDirectoryContent, AFSOptionalParameters);
        if not AFSOperationResponse.IsSuccessful() then
            if AFSOperationResponse.GetError().Contains(NotFoundTok) then
                exit(false)
            else
                Error(AFSOperationResponse.GetError());

        exit(not AFSDirectoryContent.IsEmpty());
    end;

    /// <summary>
    /// Deletes a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure DeleteDirectory(AccountId: Guid; Path: Text)
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
    begin
        InitFileClient(AccountId, AFSFileClient);
        AFSOperationResponse := AFSFileClient.DeleteDirectory(Path);

        if AFSOperationResponse.IsSuccessful() then
            exit;

        Error(AFSOperationResponse.GetError());
    end;

    /// <summary>
    /// Gets the registered accounts for the File Share connector.
    /// </summary>
    /// <param name="Accounts">Out parameter holding all the registered accounts for the File Share connector.</param>
    procedure GetAccounts(var Accounts: Record "File Account")
    var
        Account: Record "File Share Account";
    begin
        if not Account.FindSet() then
            exit;

        repeat
            Accounts."Account Id" := Account.Id;
            Accounts.Name := Account.Name;
            Accounts.Connector := Enum::"Ext. File Storage Connector"::"File Share";
            Accounts.Insert();
        until Account.Next() = 0;
    end;

    /// <summary>
    /// Shows accounts information.
    /// </summary>
    /// <param name="AccountId">The ID of the account to show.</param>
    procedure ShowAccountInformation(AccountId: Guid)
    var
        FileShareAccountLocal: Record "File Share Account";
    begin
        if not FileShareAccountLocal.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        FileShareAccountLocal.SetRecFilter();
        Page.Run(Page::"File Share Account", FileShareAccountLocal);
    end;

    /// <summary>
    /// Register an file account for the File Share connector.
    /// </summary>
    /// <param name="Account">Out parameter holding details of the registered account.</param>
    /// <returns>True if the registration was successful; false - otherwise.</returns>
    procedure RegisterAccount(var Account: Record "File Account"): Boolean
    var
        FileShareAccountWizard: Page "File Share Account Wizard";
    begin
        FileShareAccountWizard.RunModal();

        exit(FileShareAccountWizard.GetAccount(Account));
    end;

    /// <summary>
    /// Deletes an file account for the File Share connector.
    /// </summary>
    /// <param name="AccountId">The ID of the File Share account</param>
    /// <returns>True if an account was deleted.</returns>
    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        FileShareAccountLocal: Record "File Share Account";
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
    begin
        exit(ConnectorBase64LogoTxt);
    end;

    internal procedure IsAccountValid(var Account: Record "File Share Account" temporary): Boolean
    begin
        if Account.Name = '' then
            exit(false);

        if Account."Storage Account Name" = '' then
            exit(false);

        if Account."File Share Name" = '' then
            exit(false);

        exit(true);
    end;

    [NonDebuggable]
    internal procedure CreateAccount(var AccountToCopy: Record "File Share Account"; Password: Text; var FileAccount: Record "File Account")
    var
        NewFileShareAccount: Record "File Share Account";
    begin
        NewFileShareAccount.TransferFields(AccountToCopy);

        NewFileShareAccount.Id := CreateGuid();
        NewFileShareAccount.SetSecret(Password);

        NewFileShareAccount.Insert();

        FileAccount."Account Id" := NewFileShareAccount.Id;
        FileAccount.Name := NewFileShareAccount.Name;
        FileAccount.Connector := Enum::"Ext. File Storage Connector"::"File Share";
    end;

    local procedure InitFileClient(var AccountId: Guid; var AFSFileClient: Codeunit "AFS File Client")
    var
        FileShareAccount: Record "File Share Account";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
    begin
        FileShareAccount.Get(AccountId);
        case FileShareAccount."Authorization Type" of
            FileShareAccount."Authorization Type"::SasToken:
                Authorization := SetReadySAS(StorageServiceAuthorization, FileShareAccount.GetSecret(FileShareAccount."Secret Key"));
            FileShareAccount."Authorization Type"::SharedKey:
                Authorization := StorageServiceAuthorization.CreateSharedKey(FileShareAccount.GetSecret(FileShareAccount."Secret Key"));
        end;

        AFSFileClient.Initialize(FileShareAccount."Storage Account Name", FileShareAccount."File Share Name", Authorization);
    end;

    local procedure CheckPath(var Path: Text)
    begin
        if (Path <> '') and not Path.EndsWith(PathSeparator()) then
            Path += PathSeparator();
    end;

    local procedure CombinePath(Path: Text; ChildPath: Text): Text
    begin
        if Path = '' then
            exit(ChildPath);

        if not Path.EndsWith(PathSeparator()) then
            Path += PathSeparator();

        exit(Path + ChildPath);
    end;

    local procedure InitOptionalParameters(var FilePaginationData: Codeunit "File Pagination Data"; var AFSOptionalParameters: Codeunit "AFS Optional Parameters")
    begin
        AFSOptionalParameters.MaxResults(500);
        AFSOptionalParameters.Marker(FilePaginationData.GetMarker());
    end;

    local procedure ValidateListingResponse(var FilePaginationData: Codeunit "File Pagination Data"; var AFSOperationResponse: Codeunit "AFS Operation Response")
    begin
        if not AFSOperationResponse.IsSuccessful() then
            Error(AFSOperationResponse.GetError());

        FilePaginationData.SetEndOfListing(true);
    end;

    local procedure GetDirectoryContent(var AccountId: Guid; var Path: Text; var FilePaginationData: Codeunit "File Pagination Data"; var AFSDirectoryContent: Record "AFS Directory Content")
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        InitFileClient(AccountId, AFSFileClient);
        CheckPath(Path);
        InitOptionalParameters(FilePaginationData, AFSOptionalParameters);
        AFSOperationResponse := AFSFileClient.ListDirectory(Path, AFSDirectoryContent, AFSOptionalParameters);
        ValidateListingResponse(FilePaginationData, AFSOperationResponse);
    end;

    [NonDebuggable]
    local procedure SetReadySAS(var StorageServiceAuthorization: Codeunit "Storage Service Authorization"; Secret: SecretText): Interface System.Azure.Storage."Storage Service Authorization"
    begin
        exit(StorageServiceAuthorization.UseReadySAS(Secret));
    end;

    local procedure PathSeparator(): Text
    begin
        exit('/');
    end;
}