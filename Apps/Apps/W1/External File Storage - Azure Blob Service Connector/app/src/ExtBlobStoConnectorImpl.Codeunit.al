// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

using System.Text;
using System.Utilities;
using System.Azure.Storage;
using System.DataAdministration;

codeunit 4560 "Ext. Blob Sto. Connector Impl." implements "External File Storage Connector"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Ext. Blob Storage Account" = rimd;

    var
        ConnectorDescriptionTxt: Label 'Use Azure Blob Storage to store and retrieve files.';
        NotRegisteredAccountErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';
        MarkerFileNameTok: Label 'BusinessCentral.FileSystem.txt', Locked = true;

    /// <summary>
    /// Gets a List of Files stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="TempFileAccountContent">A list with all files stored in the path.</param>
    procedure ListFiles(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var TempFileAccountContent: Record "File Account Content" temporary)
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
            TempFileAccountContent.Init();
            TempFileAccountContent.Name := ABSContainerContent.Name;
            TempFileAccountContent.Type := TempFileAccountContent.Type::"File";
            TempFileAccountContent."Parent Directory" := ABSContainerContent."Parent Directory";
            TempFileAccountContent.Insert();
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

        if not ABSOperationResponse.IsSuccessful() then
            Error(ABSOperationResponse.GetError());
    end;

    /// <summary>
    /// Create a file in the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read from.</param>
    procedure CreateFile(AccountId: Guid; Path: Text; Stream: InStream)
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
        ABSContainerContent: Record "ABS Container Content";
        ABSBlobClient: Codeunit "ABS Blob Client";
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
    procedure ListDirectories(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var TempFileAccountContent: Record "File Account Content" temporary)
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
            TempFileAccountContent.Init();
            TempFileAccountContent.Name := ABSContainerContent.Name;
            TempFileAccountContent.Type := TempFileAccountContent.Type::Directory;
            TempFileAccountContent."Parent Directory" := ABSContainerContent."Parent Directory";
            TempFileAccountContent.Insert();
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
        CreateFile(AccountId, Path, IStream);
    end;

    /// <summary>
    /// Checks if a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <returns>Returns true if the directory exists</returns>
    procedure DirectoryExists(AccountId: Guid; Path: Text): Boolean
    var
        ABSContainerContent: Record "ABS Container Content";
        ABSBlobClient: Codeunit "ABS Blob Client";
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
        TempFileAccountContent: Record "File Account Content" temporary;
        FilePaginationData: Codeunit "File Pagination Data";
        DirectoryMustBeEmptyErr: Label 'Directory is not empty.';
    begin
        ListFiles(AccountId, Path, FilePaginationData, TempFileAccountContent);
        ListDirectories(AccountId, Path, FilePaginationData, TempFileAccountContent);
        TempFileAccountContent.SetFilter(Name, '<>%1', MarkerFileNameTok);
        if not TempFileAccountContent.IsEmpty() then
            Error(DirectoryMustBeEmptyErr);

        DeleteFile(AccountId, CombinePath(Path, MarkerFileNameTok));
    end;

    /// <summary>
    /// Gets the registered accounts for the Blob Storage connector.
    /// </summary>
    /// <param name="TempAccounts">Out parameter holding all the registered accounts for the Blob Storage connector.</param>
    procedure GetAccounts(var TempAccounts: Record "File Account" temporary)
    var
        Account: Record "Ext. Blob Storage Account";
    begin
        if not Account.FindSet() then
            exit;

        repeat
            TempAccounts."Account Id" := Account.Id;
            TempAccounts.Name := Account.Name;
            TempAccounts.Connector := Enum::"Ext. File Storage Connector"::"Blob Storage";
            TempAccounts.Insert();
        until Account.Next() = 0;
    end;

    /// <summary>
    /// Shows accounts information.
    /// </summary>
    /// <param name="AccountId">The ID of the account to show.</param>
    procedure ShowAccountInformation(AccountId: Guid)
    var
        BlobStorageAccountLocal: Record "Ext. Blob Storage Account";
    begin
        if not BlobStorageAccountLocal.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        BlobStorageAccountLocal.SetRecFilter();
        Page.Run(Page::"Ext. Blob Storage Account", BlobStorageAccountLocal);
    end;

    /// <summary>
    /// Register an file account for the Blob Storage connector.
    /// </summary>
    /// <param name="TempAccount">Out parameter holding details of the registered account.</param>
    /// <returns>True if the registration was successful; false - otherwise.</returns>
    procedure RegisterAccount(var TempAccount: Record "File Account" temporary): Boolean
    var
        BlobStorageAccountWizard: Page "Ext. Blob Stor. Account Wizard";
    begin
        BlobStorageAccountWizard.RunModal();

        exit(BlobStorageAccountWizard.GetAccount(TempAccount));
    end;

    /// <summary>
    /// Deletes an file account for the Blob Storage connector.
    /// </summary>
    /// <param name="AccountId">The ID of the Blob Storage account</param>
    /// <returns>True if an account was deleted.</returns>
    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        BlobStorageAccountLocal: Record "Ext. Blob Storage Account";
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
    var
        Base64Convert: Codeunit "Base64 Convert";
        Stream: InStream;
    begin
        NavApp.GetResource('connector-logo.png', Stream);
        exit(Base64Convert.ToBase64(Stream));
    end;

    internal procedure IsAccountValid(var TempAccount: Record "Ext. Blob Storage Account" temporary): Boolean
    begin
        if TempAccount.Name = '' then
            exit(false);

        if TempAccount."Storage Account Name" = '' then
            exit(false);

        if TempAccount."Container Name" = '' then
            exit(false);

        exit(true);
    end;

    internal procedure CreateAccount(var AccountToCopy: Record "Ext. Blob Storage Account"; Password: SecretText; var FileAccount: Record "File Account")
    var
        NewBlobStorageAccount: Record "Ext. Blob Storage Account";
    begin
        NewBlobStorageAccount.TransferFields(AccountToCopy);

        NewBlobStorageAccount.Id := CreateGuid();
        NewBlobStorageAccount.SetSecret(Password);

        NewBlobStorageAccount.Insert();

        FileAccount."Account Id" := NewBlobStorageAccount.Id;
        FileAccount.Name := NewBlobStorageAccount.Name;
        FileAccount.Connector := Enum::"Ext. File Storage Connector"::"Blob Storage";
    end;

    internal procedure LookUpContainer(var Account: Record "Ext. Blob Storage Account"; AuthType: Enum "Ext. Blob Storage Auth. Type"; Secret: SecretText; var NewContainerName: Text[2048])
    var
        ABSContainers: Record "ABS Container";
        ABSContainerClient: Codeunit "ABS Container Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Authorization: Interface "Storage Service Authorization";
    begin
        Account.TestField("Storage Account Name");
        case AuthType of
            AuthType::SasToken:
                Authorization := SetReadySAS(StorageServiceAuthorization, Secret);
            AuthType::SharedKey:
                Authorization := StorageServiceAuthorization.CreateSharedKey(Secret);
        end;

        ABSContainerClient.Initialize(Account."Storage Account Name", Authorization);
        ABSOperationResponse := ABSContainerClient.ListContainers(ABSContainers);
        if not ABSOperationResponse.IsSuccessful() then
            Error(ABSOperationResponse.GetError());

        if not ABSContainers.Get(NewContainerName) then
            if ABSContainers.FindFirst() then;

        if (Page.RunModal(Page::"Ext. Blob Sto Container Lookup", ABSContainers) <> Action::LookupOK) then
            exit;

        NewContainerName := ABSContainers.Name;
    end;

    local procedure InitBlobClient(var AccountId: Guid; var ABSBlobClient: Codeunit "ABS Blob Client")
    var
        BlobStorageAccount: Record "Ext. Blob Storage Account";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
        AccountDisabledErr: Label 'The account "%1" is disabled.', Comment = '%1 - Account Name';
    begin
        BlobStorageAccount.Get(AccountId);
        if BlobStorageAccount.Disabled then
            Error(AccountDisabledErr, BlobStorageAccount.Name);

        case BlobStorageAccount."Authorization Type" of
            "Ext. Blob Storage Auth. Type"::SasToken:
                Authorization := SetReadySAS(StorageServiceAuthorization, BlobStorageAccount.GetSecret(BlobStorageAccount."Secret Key"));
            "Ext. Blob Storage Auth. Type"::SharedKey:
                Authorization := StorageServiceAuthorization.CreateSharedKey(BlobStorageAccount.GetSecret(BlobStorageAccount."Secret Key"));
        end;
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

    local procedure InitOptionalParameters(Path: Text; var FilePaginationData: Codeunit "File Pagination Data"; var ABSOptionalParameters: Codeunit "ABS Optional Parameters")
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

    local procedure SetReadySAS(var StorageServiceAuthorization: Codeunit "Storage Service Authorization"; Secret: SecretText): Interface System.Azure.Storage."Storage Service Authorization"
    begin
        exit(StorageServiceAuthorization.UseReadySAS(Secret));
    end;

    local procedure PathSeparator(): Text
    begin
        exit('/');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
    local procedure EnvironmentCleanup_OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        ExtBlobStorageAccount: Record "Ext. Blob Storage Account";
    begin
        ExtBlobStorageAccount.SetRange(Disabled, false);
        if ExtBlobStorageAccount.IsEmpty() then
            exit;

        ExtBlobStorageAccount.ModifyAll(Disabled, true);
    end;
}