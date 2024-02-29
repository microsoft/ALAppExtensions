// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

using System.Utilities;
using System.Azure.Storage;

codeunit 80100 "Blob Storage Connector Impl." implements "File System Connector"
{
    Access = Internal;
    Permissions = tabledata "Blob Storage Account" = rimd;

    var
        ConnectorDescriptionTxt: Label 'Use Azure Blob Storage to store and retrieve files.';
        NotRegisteredAccountErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';
        ConnectorBase64LogoTxt: Label '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', Locked = true;
        MarkerFileNameTok: Label 'BusinessCentral.FileSystem.txt', Locked = true;

    /// <summary>
    /// Gets a List of Files stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="Files">A list with all files stored in the path.</param>
    procedure ListFiles(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var FileAccountContent: Record "File Account Content" temporary)
    var
        ABSContainerContent: Record "ABS Container Content";
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ABSOptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        InitBlobClient(AccountId, ABSBlobClient);
        CheckPath(Path);
        InitOptionalParameters(Path, FilePaginationData, ABSOptionalParameters);
        ABSOptionalParameters.Delimiter('/');
        ABSOperationResponse := ABSBlobClient.ListBlobs(ABSContainerContent, ABSOptionalParameters);
        ValidateListingResponse(FilePaginationData, ABSOperationResponse);

        ABSContainerContent.SetFilter("Blob Type", '<>%1', '');
        ABSContainerContent.SetFilter(Name, '<>%1', MarkerFileNameTok);
        if not ABSContainerContent.FindSet() then
            exit;

        repeat
            FileAccountContent.Init();
            FileAccountContent.Name := ABSContainerContent.Name;
            FileAccountContent.Type := FileAccountContent.Type::"File";
            FileAccountContent."Parent Directory" := ABSContainerContent."Parent Directory";
            FileAccountContent.Insert();
        until ABSContainerContent.Next() = 0;
    end;

    /// <summary>
    /// Gets a file from the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read to.</param>
    procedure GetFile(AccountId: Guid; Path: Text; Stream: InStream)
    var
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        InitBlobClient(AccountId, ABSBlobClient);
        ABSOperationResponse := ABSBlobClient.GetBlobAsStream(Path, Stream);

        if ABSOperationResponse.IsSuccessful() then
            exit;

        Error(ABSOperationResponse.GetError());
    end;

    /// <summary>
    /// Gets a file to the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read from.</param>
    procedure SetFile(AccountId: Guid; Path: Text; Stream: InStream)
    var
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        InitBlobClient(AccountId, ABSBlobClient);
        ABSOperationResponse := ABSBlobClient.PutBlobBlockBlobStream(Path, Stream);

        if ABSOperationResponse.IsSuccessful() then
            exit;

        Error(ABSOperationResponse.GetError());
    end;

    /// <summary>
    /// Copies as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure CopyFile(AccountId: Guid; SourcePath: Text; TargetPath: Text)
    var
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        InitBlobClient(AccountId, ABSBlobClient);
        ABSOperationResponse := ABSBlobClient.CopyBlob(TargetPath, SourcePath);

        if ABSOperationResponse.IsSuccessful() then
            exit;

        Error(ABSOperationResponse.GetError());
    end;

    /// <summary>
    /// Move as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure MoveFile(AccountId: Guid; SourcePath: Text; TargetPath: Text)
    var
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        InitBlobClient(AccountId, ABSBlobClient);
        ABSOperationResponse := ABSBlobClient.CopyBlob(TargetPath, SourcePath);
        if not ABSOperationResponse.IsSuccessful() then
            Error(ABSOperationResponse.GetError());

        ABSOperationResponse := ABSBlobClient.DeleteBlob(SourcePath);
        if not ABSOperationResponse.IsSuccessful() then
            Error(ABSOperationResponse.GetError());
    end;

    /// <summary>
    /// Checks if a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <returns>Returns true if the file exists</returns>
    procedure FileExists(AccountId: Guid; Path: Text): Boolean
    var
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSContainerContent: Record "ABS Container Content";
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ABSOptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        if Path = '' then
            exit(false);

        InitBlobClient(AccountId, ABSBlobClient);
        ABSOptionalParameters.Prefix(Path);
        ABSOperationResponse := ABSBlobClient.ListBlobs(ABSContainerContent, ABSOptionalParameters);
        if not ABSOperationResponse.IsSuccessful() then
            Error(ABSOperationResponse.GetError());

        exit(not ABSContainerContent.IsEmpty());
    end;

    /// <summary>
    /// Deletes a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    procedure DeleteFile(AccountId: Guid; Path: Text)
    var
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        InitBlobClient(AccountId, ABSBlobClient);
        ABSOperationResponse := ABSBlobClient.DeleteBlob(Path);

        if ABSOperationResponse.IsSuccessful() then
            exit;

        Error(ABSOperationResponse.GetError());
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
        ABSContainerContent: Record "ABS Container Content";
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ABSOptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        InitBlobClient(AccountId, ABSBlobClient);
        CheckPath(Path);
        InitOptionalParameters(Path, FilePaginationData, ABSOptionalParameters);
        ABSOperationResponse := ABSBlobClient.ListBlobs(ABSContainerContent, ABSOptionalParameters);
        ValidateListingResponse(FilePaginationData, ABSOperationResponse);

        ABSContainerContent.SetRange("Parent Directory", Path);
        ABSContainerContent.SetRange("Blob Type", '');
        if not ABSContainerContent.FindSet() then
            exit;

        repeat
            FileAccountContent.Init();
            FileAccountContent.Name := ABSContainerContent.Name;
            FileAccountContent.Type := FileAccountContent.Type::Directory;
            FileAccountContent."Parent Directory" := ABSContainerContent."Parent Directory";
            FileAccountContent.Insert();
        until ABSContainerContent.Next() = 0;
    end;

    /// <summary>
    /// Creates a directory on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure CreateDirectory(AccountId: Guid; Path: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        FileSystem: Codeunit "File System";
        IStream: InStream;
        OStream: OutStream;
        DirectoryAlreadyExistsErr: Label 'Directory already exists.';
        MarkerFileContentTok: Label 'This is a directory marker file created by Business Central. It is safe to delete it.', Locked = true;
    begin
        if DirectoryExists(AccountId, Path) then
            Error(DirectoryAlreadyExistsErr);

        Path := CombinePath(Path, MarkerFileNameTok);
        TempBlob.CreateOutStream(OStream);
        OStream.WriteText(MarkerFileContentTok);

        TempBlob.CreateInStream(IStream);
        SetFile(AccountId, Path, IStream);
    end;

    /// <summary>
    /// Checks if a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <returns>Returns true if the directory exists</returns>
    procedure DirectoryExists(AccountId: Guid; Path: Text): Boolean
    var
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSContainerContent: Record "ABS Container Content";
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ABSOptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        if Path = '' then
            exit(true);

        InitBlobClient(AccountId, ABSBlobClient);
        ABSOptionalParameters.Prefix(Path);
        ABSOptionalParameters.MaxResults(1);
        ABSOperationResponse := ABSBlobClient.ListBlobs(ABSContainerContent, ABSOptionalParameters);
        if not ABSOperationResponse.IsSuccessful() then
            Error(ABSOperationResponse.GetError());

        exit(not ABSContainerContent.IsEmpty());
    end;

    /// <summary>
    /// Deletes a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure DeleteDirectory(AccountId: Guid; Path: Text)
    var
        FileAccountContent: Record "File Account Content" temporary;
        FilePaginationData: Codeunit "File Pagination Data";
        DirectoryMustBeEmptyErr: Label 'Directory is not empty.';
    begin
        ListFiles(AccountId, Path, FilePaginationData, FileAccountContent);
        ListDirectories(AccountId, Path, FilePaginationData, FileAccountContent);
        FileAccountContent.SetFilter(Name, '<>%1', MarkerFileNameTok);
        if not FileAccountContent.IsEmpty() then
            Error(DirectoryMustBeEmptyErr);

        DeleteFile(AccountId, CombinePath(Path, MarkerFileNameTok));
    end;

    /// <summary>
    /// Returns the path separator of the file account.
    /// </summary>
    /// <returns>The Path separator like / or \</returns>
    procedure PathSeparator(): Text
    begin
        exit('/');
    end;

    /// <summary>
    /// Gets the registered accounts for the Blob Storage connector.
    /// </summary>
    /// <param name="Accounts">Out parameter holding all the registered accounts for the Blob Storage connector.</param>
    procedure GetAccounts(var Accounts: Record "File Account")
    var
        Account: Record "Blob Storage Account";
    begin
        if not Account.FindSet() then
            exit;

        repeat
            Accounts."Account Id" := Account.Id;
            Accounts.Name := Account.Name;
            Accounts.Connector := Enum::"File System Connector"::"Blob Storage";
            Accounts.Insert();
        until Account.Next() = 0;
    end;

    /// <summary>
    /// Shows accounts information.
    /// </summary>
    /// <param name="AccountId">The ID of the account to show.</param>
    procedure ShowAccountInformation(AccountId: Guid)
    var
        BlobStorageAccountLocal: Record "Blob Storage Account";
    begin
        if not BlobStorageAccountLocal.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        BlobStorageAccountLocal.SetRecFilter();
        Page.Run(Page::"Blob Storage Account", BlobStorageAccountLocal);
    end;

    /// <summary>
    /// Register an file account for the Blob Storage connector.
    /// </summary>
    /// <param name="Account">Out parameter holding details of the registered account.</param>
    /// <returns>True if the registration was successful; false - otherwise.</returns>
    procedure RegisterAccount(var Account: Record "File Account"): Boolean
    var
        BlobStorageAccountWizard: Page "Blob Storage Account Wizard";
    begin
        BlobStorageAccountWizard.RunModal();

        exit(BlobStorageAccountWizard.GetAccount(Account));
    end;

    /// <summary>
    /// Deletes an file account for the Blob Storage connector.
    /// </summary>
    /// <param name="AccountId">The ID of the Blob Storage account</param>
    /// <returns>True if an account was deleted.</returns>
    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        BlobStorageAccountLocal: Record "Blob Storage Account";
    begin
        if BlobStorageAccountLocal.Get(AccountId) then
            exit(BlobStorageAccountLocal.Delete());

        exit(false);
    end;

    /// <summary>
    /// Gets a description of the Blob Storage connector.
    /// </summary>
    /// <returns>A short description of the Blob Storage connector.</returns>
    procedure GetDescription(): Text[250]
    begin
        exit(ConnectorDescriptionTxt);
    end;

    /// <summary>
    /// Gets the Blob Storage connector logo.
    /// </summary>
    /// <returns>A base64-formatted image to be used as logo.</returns>
    procedure GetLogoAsBase64(): Text
    begin
        exit(ConnectorBase64LogoTxt);
    end;

    internal procedure IsAccountValid(var Account: Record "Blob Storage Account" temporary): Boolean
    begin
        if Account.Name = '' then
            exit(false);

        if Account."Storage Account Name" = '' then
            exit(false);

        if Account."Container Name" = '' then
            exit(false);

        exit(true);
    end;

    [NonDebuggable]
    internal procedure CreateAccount(var AccountToCopy: Record "Blob Storage Account"; Password: Text; var FileAccount: Record "File Account")
    var
        NewBlobStorageAccount: Record "Blob Storage Account";
    begin
        NewBlobStorageAccount.TransferFields(AccountToCopy);

        NewBlobStorageAccount.Id := CreateGuid();
        NewBlobStorageAccount.SetPassword(Password);

        NewBlobStorageAccount.Insert();

        FileAccount."Account Id" := NewBlobStorageAccount.Id;
        FileAccount.Name := NewBlobStorageAccount.Name;
        FileAccount.Connector := Enum::"File System Connector"::"Blob Storage";
    end;

    internal procedure LookUpContainer(var Account: Record "Blob Storage Account"; Password: SecretText; var NewContainerName: Text[2048])
    var
        ABSContainers: Record "ABS Container";
        ABSContainerClient: Codeunit "ABS Container Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Authorization: Interface "Storage Service Authorization";
    begin
        Account.TestField("Storage Account Name");
        Authorization := StorageServiceAuthorization.CreateSharedKey(Password);
        ABSContainerClient.Initialize(Account."Storage Account Name", Authorization);
        ABSOperationResponse := ABSContainerClient.ListContainers(ABSContainers);
        if not ABSOperationResponse.IsSuccessful() then
            Error(ABSOperationResponse.GetError());

        if not ABSContainers.Get(NewContainerName) then
            if ABSContainers.FindFirst() then;

        if (Page.RunModal(Page::"Blob Storage Container Lookup", ABSContainers) <> Action::LookupOK) then
            exit;

        NewContainerName := ABSContainers.Name;
    end;

    local procedure InitBlobClient(var AccountId: Guid; var ABSBlobClient: Codeunit "ABS Blob Client")
    var
        BlobStorageAccount: Record "Blob Storage Account";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
    begin
        BlobStorageAccount.Get(AccountId);
        Authorization := StorageServiceAuthorization.CreateSharedKey(BlobStorageAccount.GetPassword(BlobStorageAccount."Password Key"));
        ABSBlobClient.Initialize(BlobStorageAccount."Storage Account Name", BlobStorageAccount."Container Name", Authorization);
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

    local procedure InitOptionalParameters(var Path: Text; var FilePaginationData: Codeunit "File Pagination Data"; var ABSOptionalParameters: Codeunit "ABS Optional Parameters")
    begin
        ABSOptionalParameters.Prefix(Path);
        ABSOptionalParameters.MaxResults(500);
        ABSOptionalParameters.NextMarker(FilePaginationData.GetMarker());
    end;

    local procedure ValidateListingResponse(var FilePaginationData: Codeunit "File Pagination Data"; var ABSOperationResponse: Codeunit "ABS Operation Response")
    begin
        if not ABSOperationResponse.IsSuccessful() then
            Error(ABSOperationResponse.GetError());

        FilePaginationData.SetMarker(ABSOperationResponse.GetNextMarker());
        FilePaginationData.SetEndOfListing(ABSOperationResponse.GetNextMarker() = '');
    end;
}