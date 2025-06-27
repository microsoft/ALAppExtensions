// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

using System.Utilities;
using System.Text;
using System.Azure.Storage;
using System.Azure.Storage.Files;
using System.DataAdministration;

codeunit 4570 "Ext. File Share Connector Impl" implements "External File Storage Connector"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Ext. File Share Account" = rimd;

    var
        ConnectorDescriptionTxt: Label 'Use Azure File Share to store and retrieve files.';
        NotRegisteredAccountErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';
        NotFoundTok: Label '404', Locked = true;

    /// <summary>
    /// Gets a List of Files stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="TempFileAccountContent">A list with all files stored in the path.</param>
    procedure ListFiles(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var TempFileAccountContent: Record "File Account Content" temporary)
    var
        AFSDirectoryContent: Record "AFS Directory Content";
    begin
        GetDirectoryContent(AccountId, Path, FilePaginationData, AFSDirectoryContent);

        AFSDirectoryContent.SetRange("Parent Directory", Path);
        AFSDirectoryContent.SetRange("Resource Type", AFSDirectoryContent."Resource Type"::File);
        if not AFSDirectoryContent.FindSet() then
            exit;

        repeat
            TempFileAccountContent.Init();
            TempFileAccountContent.Name := AFSDirectoryContent.Name;
            TempFileAccountContent.Type := TempFileAccountContent.Type::"File";
            TempFileAccountContent."Parent Directory" := AFSDirectoryContent."Parent Directory";
            TempFileAccountContent.Insert();
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

        if not AFSOperationResponse.IsSuccessful() then
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
        SourcePathUri: Text;
    begin
        InitFileClient(AccountId, AFSFileClient);
        SourcePathUri := CreateUri(AccountId, SourcePath);
        AFSOperationResponse := AFSFileClient.CopyFile(SourcePathUri, TargetPath);

        if not AFSOperationResponse.IsSuccessful() then
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
        AFSOperationResponse: Codeunit "AFS Operation Response";
        TargetMetaData: Dictionary of [Text, Text];
    begin
        if Path = '' then
            exit(false);

        InitFileClient(AccountId, AFSFileClient);

        AFSOperationResponse := AFSFileClient.GetFileMetadata(Path, TargetMetaData);
        if AFSOperationResponse.IsSuccessful() then
            exit(true);

        if AFSOperationResponse.GetError().Contains(NotFoundTok) then
            exit(false);

        Error(AFSOperationResponse.GetError());
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

        if not AFSOperationResponse.IsSuccessful() then
            Error(AFSOperationResponse.GetError());
    end;

    /// <summary>
    /// Gets a List of Directories stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="Files">A list with all directories stored in the path.</param>
    procedure ListDirectories(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var TempFileAccountContent: Record "File Account Content" temporary)
    var
        AFSDirectoryContent: Record "AFS Directory Content";
    begin
        GetDirectoryContent(AccountId, Path, FilePaginationData, AFSDirectoryContent);

        AFSDirectoryContent.SetRange("Parent Directory", Path);
        AFSDirectoryContent.SetRange("Resource Type", AFSDirectoryContent."Resource Type"::Directory);
        if not AFSDirectoryContent.FindSet() then
            exit;

        repeat
            TempFileAccountContent.Init();
            TempFileAccountContent.Name := AFSDirectoryContent.Name;
            TempFileAccountContent.Type := TempFileAccountContent.Type::Directory;
            TempFileAccountContent."Parent Directory" := AFSDirectoryContent."Parent Directory";
            TempFileAccountContent.Insert();
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
        AFSDirectoryContent: Record "AFS Directory Content";
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        if Path = '' then
            exit(true);

        InitFileClient(AccountId, AFSFileClient);
        AFSOptionalParameters.MaxResults(1);
        AFSOperationResponse := AFSFileClient.ListDirectory(CopyStr(Path, 1, 2048), AFSDirectoryContent, AFSOptionalParameters);
        if AFSOperationResponse.IsSuccessful() then
            exit(true);

        if AFSOperationResponse.GetError().Contains(NotFoundTok) then
            exit(false)
        else
            Error(AFSOperationResponse.GetError());
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

        if not AFSOperationResponse.IsSuccessful() then
            Error(AFSOperationResponse.GetError());
    end;

    /// <summary>
    /// Gets the registered accounts for the File Share connector.
    /// </summary>
    /// <param name="TempAccounts">Out parameter holding all the registered accounts for the File Share connector.</param>
    procedure GetAccounts(var TempAccounts: Record "File Account" temporary)
    var
        Account: Record "Ext. File Share Account";
    begin
        if not Account.FindSet() then
            exit;

        repeat
            TempAccounts."Account Id" := Account.Id;
            TempAccounts.Name := Account.Name;
            TempAccounts.Connector := Enum::"Ext. File Storage Connector"::"File Share";
            TempAccounts.Insert();
        until Account.Next() = 0;
    end;

    /// <summary>
    /// Shows accounts information.
    /// </summary>
    /// <param name="AccountId">The ID of the account to show.</param>
    procedure ShowAccountInformation(AccountId: Guid)
    var
        FileShareAccountLocal: Record "Ext. File Share Account";
    begin
        if not FileShareAccountLocal.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        FileShareAccountLocal.SetRecFilter();
        Page.Run(Page::"Ext. File Share Account", FileShareAccountLocal);
    end;

    /// <summary>
    /// Register an file account for the File Share connector.
    /// </summary>
    /// <param name="TempAccount">Out parameter holding details of the registered account.</param>
    /// <returns>True if the registration was successful; false - otherwise.</returns>
    procedure RegisterAccount(var TempAccount: Record "File Account" temporary): Boolean
    var
        FileShareAccountWizard: Page "Ext. File Share Account Wizard";
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
        FileShareAccountLocal: Record "Ext. File Share Account";
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

    internal procedure IsAccountValid(var Account: Record "Ext. File Share Account" temporary): Boolean
    begin
        if Account.Name = '' then
            exit(false);

        if Account."Storage Account Name" = '' then
            exit(false);

        if Account."File Share Name" = '' then
            exit(false);

        exit(true);
    end;

    internal procedure CreateAccount(var AccountToCopy: Record "Ext. File Share Account"; Password: SecretText; var TempFileAccount: Record "File Account" temporary)
    var
        NewFileShareAccount: Record "Ext. File Share Account";
    begin
        NewFileShareAccount.TransferFields(AccountToCopy);

        NewFileShareAccount.Id := CreateGuid();
        NewFileShareAccount.SetSecret(Password);

        NewFileShareAccount.Insert();

        TempFileAccount."Account Id" := NewFileShareAccount.Id;
        TempFileAccount.Name := NewFileShareAccount.Name;
        TempFileAccount.Connector := Enum::"Ext. File Storage Connector"::"File Share";
    end;

    local procedure InitFileClient(var AccountId: Guid; var AFSFileClient: Codeunit "AFS File Client")
    var
        FileShareAccount: Record "Ext. File Share Account";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
        AccountDisabledErr: Label 'The account "%1" is disabled.', Comment = '%1 - Account Name';
    begin
        FileShareAccount.Get(AccountId);
        if FileShareAccount.Disabled then
            Error(AccountDisabledErr, FileShareAccount.Name);

        case FileShareAccount."Authorization Type" of
            FileShareAccount."Authorization Type"::SasToken:
                Authorization := SetReadySAS(StorageServiceAuthorization, FileShareAccount.GetSecret(FileShareAccount."Secret Key"));
            FileShareAccount."Authorization Type"::SharedKey:
                Authorization := StorageServiceAuthorization.CreateSharedKey(FileShareAccount.GetSecret(FileShareAccount."Secret Key"));
        end;

        AFSFileClient.Initialize(FileShareAccount."Storage Account Name", FileShareAccount."File Share Name", Authorization);
    end;

    local procedure CheckPath(var Path: Text)
    var
        PathToLongErr: Label 'The path is too long. The maximum length is 2048 characters.';
    begin
        if (Path <> '') and not Path.EndsWith(PathSeparator()) then
            Path += PathSeparator();

        if StrLen(Path) > 2048 then
            Error(PathToLongErr);
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

    local procedure GetDirectoryContent(var AccountId: Guid; var PassedPath: Text; var FilePaginationData: Codeunit "File Pagination Data"; var AFSDirectoryContent: Record "AFS Directory Content")
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
        Path: Text[2048];
    begin
        InitFileClient(AccountId, AFSFileClient);
        CheckPath(PassedPath);
        InitOptionalParameters(FilePaginationData, AFSOptionalParameters);
        Path := CopyStr(PassedPath, 1, MaxStrLen(Path));
        AFSOperationResponse := AFSFileClient.ListDirectory(Path, AFSDirectoryContent, AFSOptionalParameters);
        PassedPath := Path;
        ValidateListingResponse(FilePaginationData, AFSOperationResponse);
    end;

    local procedure SetReadySAS(var StorageServiceAuthorization: Codeunit "Storage Service Authorization"; Secret: SecretText): Interface System.Azure.Storage."Storage Service Authorization"
    begin
        exit(StorageServiceAuthorization.UseReadySAS(Secret));
    end;

    local procedure PathSeparator(): Text
    begin
        exit('/');
    end;

    local procedure CreateUri(AccountId: Guid; SourcePath: Text): Text
    var
        FileShareAccount: Record "Ext. File Share Account";
        Uri: Codeunit Uri;
        FileShareUriLbl: Label 'https://%1.file.core.windows.net/%2/%3', Locked = true;
    begin
        FileShareAccount.Get(AccountId);
        FileShareAccount.TestField("Storage Account Name");
        FileShareAccount.TestField("File Share Name");
        exit(StrSubstNo(FileShareUriLbl, FileShareAccount."Storage Account Name", FileShareAccount."File Share Name", Uri.EscapeDataString(SourcePath)));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
    local procedure EnvironmentCleanup_OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        ExtFileShareAccount: Record "Ext. File Share Account";
    begin
        ExtFileShareAccount.SetRange(Disabled, false);
        if ExtFileShareAccount.IsEmpty() then
            exit;

        ExtFileShareAccount.ModifyAll(Disabled, true);
    end;
}
