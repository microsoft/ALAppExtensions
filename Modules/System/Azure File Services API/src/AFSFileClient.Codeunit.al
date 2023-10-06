// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to access the Azure File Storage.
/// </summary>
codeunit 8950 "AFS File Client"
{
    Access = Public;

    var
        AFSFileClientImpl: Codeunit "AFS File Client Impl.";

    /// <summary>
    /// Initializes the AFS Client.
    /// </summary>
    /// <param name="StorageAccount">The name of the storage account to use.</param>
    /// <param name="FileShare">The name of the file share to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    procedure Initialize(StorageAccount: Text; FileShare: Text; Authorization: Interface "Storage Service Authorization")
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
    begin
        AFSFileClientImpl.Initialize(StorageAccount, FileShare, '', Authorization, StorageServiceAuthorization.GetDefaultAPIVersion());
    end;

    /// <summary>
    /// Initializes the AFS Client.
    /// </summary>
    /// <param name="StorageAccount">The name of the storage account to use.</param>
    /// <param name="FileShare">The name of the file share to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    /// <param name="APIVersion">The API Version to use.</param>
    procedure Initialize(StorageAccount: Text; FileShare: Text; Authorization: Interface "Storage Service Authorization"; APIVersion: Enum "Storage Service API Version")
    begin
        AFSFileClientImpl.Initialize(StorageAccount, FileShare, '', Authorization, APIVersion);
    end;

    /// <summary>
    /// Creates a file in the file share.
    /// This does not fill in the file content, it only initializes the file.
    /// </summary>
    /// <param name="FilePath">The path where the file will be created.</param>
    /// <param name="InStream">The file content, only used to check file size.</param>
    /// <returns>An operation response object.</returns>
    procedure CreateFile(FilePath: Text; InStream: InStream): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.CreateFile(FilePath, InStream, AFSOptionalParameters));
    end;

    /// <summary>
    /// Creates a file in the file share.
    /// This does not fill in the file content, it only initializes the file.
    /// </summary>
    /// <param name="FilePath">The path where the file will be created.</param>
    /// <param name="InStream">The file content, only used to check file size.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object.</returns>
    procedure CreateFile(FilePath: Text; InStream: InStream; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.CreateFile(FilePath, InStream, AFSOptionalParameters));
    end;

    /// <summary>
    /// Creates a file in the file share.
    /// This does not fill in the file content, it only initializes the file.
    /// </summary>
    /// <param name="FilePath">The path where the file will be created.</param>
    /// <param name="FileSize">The size of the file to initialize, in bytes.</param>
    /// <returns>An operation response object.</returns>
    procedure CreateFile(FilePath: Text; FileSize: Integer): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.CreateFile(FilePath, FileSize, AFSOptionalParameters));
    end;

    /// <summary>
    /// Creates a file in the file share.
    /// This does not fill in the file content, it only initializes the file.
    /// </summary>
    /// <param name="FilePath">The path where the file will be created.</param>
    /// <param name="FileSize">The size of the file to initialize, in bytes.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object.</returns>
    procedure CreateFile(FilePath: Text; FileSize: Integer; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.CreateFile(FilePath, FileSize, AFSOptionalParameters));
    end;

    /// <summary>
    /// Receives a file as a File from a file share.
    /// The file will be downloaded through the browser.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <returns>An operation response object</returns>
    procedure GetFileAsFile(FilePath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.GetFileAsFile(FilePath, AFSOptionalParameters));
    end;

    /// <summary>
    /// Receives a file as a File from a file share.
    /// The file will be downloaded through the browser.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure GetFileAsFile(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.GetFileAsFile(FilePath, AFSOptionalParameters));
    end;

    /// <summary>
    /// Receives a file as a stream from a file share.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="TargetInStream">The result instream containing the content of the file.</param>
    /// <returns>An operation response object</returns>
    procedure GetFileAsStream(FilePath: Text; var TargetInStream: InStream): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.GetFileAsStream(FilePath, TargetInStream, AFSOptionalParameters));
    end;

    /// <summary>
    /// Receives a file as a stream from a file share.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="TargetInStream">The result instream containing the  content of the file.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure GetFileAsStream(FilePath: Text; var TargetInStream: InStream; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.GetFileAsStream(FilePath, TargetInStream, AFSOptionalParameters));
    end;

    /// <summary>
    /// Receives a file as a text from a file share.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="TargetText">The result text containing the content of the file.</param>
    /// <returns>An operation response object</returns>
    procedure GetFileAsText(FilePath: Text; var TargetText: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.GetFileAsText(FilePath, TargetText, AFSOptionalParameters));
    end;

    /// <summary>
    /// Receives a file as a text from a file share.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="TargetText">The result text containing the content of the file.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure GetFileAsText(FilePath: Text; var TargetText: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.GetFileAsText(FilePath, TargetText, AFSOptionalParameters));
    end;

    /// <summary>
    /// Receives file metadata as dictionary from a file share.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="TargetMetadata">The result dictionary containing the metadata of the file in the form of metadata key and a value.</param>
    /// <returns>An operation response object</returns>
    procedure GetFileMetadata(FilePath: Text; var TargetMetadata: Dictionary of [Text, Text]): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.GetFileMetadata(FilePath, TargetMetadata, AFSOptionalParameters));
    end;

    /// <summary>
    /// Receives file metadata as dictionary from a file share.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="TargetMetadata">The result dictionary containing the metadata of the file in the form of metadata key and a value.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure GetFileMetadata(FilePath: Text; var TargetMetadata: Dictionary of [Text, Text]; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.GetFileMetadata(FilePath, TargetMetadata, AFSOptionalParameters));
    end;

    /// <summary>
    /// Sets the file metadata.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="Metadata">The dictionary containing the metadata of the file in the form of metadata key and a value.</param>
    /// <returns>An operation response object</returns>
    procedure SetFileMetadata(FilePath: Text; Metadata: Dictionary of [Text, Text]): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.SetFileMetadata(FilePath, Metadata, AFSOptionalParameters));
    end;

    /// <summary>
    /// Sets the file metadata.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="Metadata">The dictionary containing the metadata of the file in the form of metadata key and a value.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure SetFileMetadata(FilePath: Text; var Metadata: Dictionary of [Text, Text]; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.SetFileMetadata(FilePath, Metadata, AFSOptionalParameters));
    end;

    /// <summary>
    /// Uploads a file to the file share.
    /// User will be prompted to specify the file to send.
    /// </summary>
    /// <returns>An operation response object</returns>
    procedure PutFileUI(): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.PutFileUI(AFSOptionalParameters));
    end;

    /// <summary>
    /// Uploads a file to the file share.
    /// User will be prompted to specify the file to send.
    /// </summary>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure PutFileUI(AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.PutFileUI(AFSOptionalParameters));
    end;

    /// <summary>
    /// Uploads a file to the file share from instream.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="SourceInStream">The source instream containing the content of the file.</param>
    /// <returns>An operation response object</returns>
    procedure PutFileStream(FilePath: Text; var SourceInStream: InStream): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.PutFileStream(FilePath, SourceInStream, AFSOptionalParameters));
    end;

    /// <summary>
    /// Uploads a file to the file share from instream.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="SourceInStream">The source instream containing the content of the file.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure PutFileStream(FilePath: Text; var SourceInStream: InStream; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.PutFileStream(FilePath, SourceInStream, AFSOptionalParameters));
    end;

    /// <summary>
    /// Uploads a file to the file share from text.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="SourceText">The source text containing the content of the file.</param>
    /// <returns>An operation response object</returns>
    procedure PutFileText(FilePath: Text; SourceText: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.PutFileText(FilePath, SourceText, AFSOptionalParameters));
    end;

    /// <summary>
    /// Uploads a file to the file share from text.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="SourceText">The source text containing the content of the file.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure PutFileText(FilePath: Text; SourceText: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.PutFileText(FilePath, SourceText, AFSOptionalParameters));
    end;

    /// <summary>
    /// Deletes a file from the file share.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <returns>An operation response object</returns>
    procedure DeleteFile(FilePath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.DeleteFile(FilePath, AFSOptionalParameters));
    end;

    /// <summary>
    /// Deletes a file from the file share.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure DeleteFile(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.DeleteFile(FilePath, AFSOptionalParameters));
    end;

    /// <summary>
    /// Lists files and directories from the file share.
    /// </summary>
    /// <param name="DirectoryPath">The path of the directory to list.</param>
    /// <param name="AFSDirectoryContent">The result collection with contents of the directory (temporary)</param>
    /// <returns>An operation response object</returns>
    procedure ListDirectory(DirectoryPath: Text[2048]; var AFSDirectoryContent: Record "AFS Directory Content"): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.ListDirectory(DirectoryPath, AFSDirectoryContent, false, AFSOptionalParameters));
    end;

    /// <summary>
    /// Lists files and directories from the file share.
    /// </summary>
    /// <param name="DirectoryPath">The path of the directory to list.</param>
    /// <param name="AFSDirectoryContent">The result collection with contents of the directory (temporary)</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure ListDirectory(DirectoryPath: Text[2048]; var AFSDirectoryContent: Record "AFS Directory Content"; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.ListDirectory(DirectoryPath, AFSDirectoryContent, false, AFSOptionalParameters));
    end;

    /// <summary>
    /// Lists files and directories from the file share.
    /// </summary>
    /// <param name="DirectoryPath">The path of the directory to list.</param>
    /// <param name="PreserveDirectoryContent">Specifies if the result collection should be cleared before filling it with the response data.</param>
    /// <param name="AFSDirectoryContent">The result collection with contents of the directory (temporary)</param>
    /// <returns>An operation response object</returns>
    procedure ListDirectory(DirectoryPath: Text[2048]; PreserveDirectoryContent: Boolean; var AFSDirectoryContent: Record "AFS Directory Content"): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.ListDirectory(DirectoryPath, AFSDirectoryContent, PreserveDirectoryContent, AFSOptionalParameters));
    end;

    /// <summary>
    /// Lists files and directories from the file share.
    /// </summary>
    /// <param name="DirectoryPath">The path of the directory to list.</param>
    /// <param name="PreserveDirectoryContent">Specifies if the result collection should be cleared before filling it with the response data.</param>
    /// <param name="AFSDirectoryContent">The result collection with contents of the directory (temporary)</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure ListDirectory(DirectoryPath: Text[2048]; PreserveDirectoryContent: Boolean; var AFSDirectoryContent: Record "AFS Directory Content"; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.ListDirectory(DirectoryPath, AFSDirectoryContent, PreserveDirectoryContent, AFSOptionalParameters));
    end;

    /// <summary>
    /// Creates directory on the file share.
    /// </summary>
    /// <param name="DirectoryPath">The path of the directory to create.</param>
    /// <returns>An operation response object</returns>
    procedure CreateDirectory(DirectoryPath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.CreateDirectory(DirectoryPath, AFSOptionalParameters));
    end;

    /// <summary>
    /// Creates directory on the file share.
    /// </summary>
    /// <param name="DirectoryPath">The path of the directory to create.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure CreateDirectory(DirectoryPath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.CreateDirectory(DirectoryPath, AFSOptionalParameters));
    end;

    /// <summary>
    /// Deletes an empty directory from the file share.
    /// </summary>
    /// <param name="DirectoryPath">The path of the directory to delete.</param>
    /// <returns>An operation response object</returns>
    procedure DeleteDirectory(DirectoryPath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.DeleteDirectory(DirectoryPath, AFSOptionalParameters));
    end;

    /// <summary>
    /// Deletes an empty directory from the file share.
    /// </summary>
    /// <param name="DirectoryPath">The path of the directory to delete.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure DeleteDirectory(DirectoryPath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.DeleteDirectory(DirectoryPath, AFSOptionalParameters));
    end;

    /// <summary>
    /// Copies a file on the file share.
    /// </summary>
    /// <param name="SourceFileURI">The URI to the source file. If the source file is on a different share than the destination file, the URI needs to be authorized.</param>
    /// <param name="DestinationFilePath">The path where to destination file should be created.</param>
    /// <returns>An operation response object</returns>
    procedure CopyFile(SourceFileURI: Text; DestinationFilePath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.CopyFile(SourceFileURI, DestinationFilePath, AFSOptionalParameters));
    end;

    /// <summary>
    /// Copies a file on the file share.
    /// </summary>
    /// <param name="SourceFileURI">The URI to the source file. If the source file is on a different share than the destination file, the URI needs to be authorized.</param>
    /// <param name="DestinationFilePath">The path where to destination file should be created.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure CopyFile(SourceFileURI: Text; DestinationFilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.CopyFile(SourceFileURI, DestinationFilePath, AFSOptionalParameters));
    end;

    /// <summary>
    /// Stops a file copy operation that is in progress.
    /// </summary>
    /// <param name="DestinationFilePath">The path where to destination file should be created.</param>
    /// <param name="CopyID">The ID of the copy opeartion to abort.</param>
    /// <returns>An operation response object</returns>
    procedure AbortCopyFile(DestinationFilePath: Text; CopyID: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.AbortCopyFile(DestinationFilePath, CopyID, AFSOptionalParameters));
    end;

    /// <summary>
    /// Stops a file copy operation that is in progress.
    /// </summary>
    /// <param name="DestinationFilePath">The path where to destination file should be created.</param>
    /// <param name="CopyID">The ID of the copy opeartion to abort.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure AbortCopyFile(DestinationFilePath: Text; CopyID: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.AbortCopyFile(DestinationFilePath, CopyID, AFSOptionalParameters));
    end;

    /// <summary>
    /// Lists all the open handles to the file.
    /// </summary>
    /// <param name="Path">The path to the file.</param>
    /// <param name="AFSHandle">The result collection containing all the handles to the file (temporary).</param>
    /// <returns>An operation response object</returns>
    procedure ListHandles(Path: Text; var AFSHandle: Record "AFS Handle"): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.ListFileHandles(Path, AFSHandle, AFSOptionalParameters));
    end;

    /// <summary>
    /// Lists all the open handles to the file.
    /// </summary>
    /// <param name="Path">The path to the file.</param>
    /// <param name="AFSHandle">The result collection containing all the handles to the file (temporary).</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure ListHandles(Path: Text; var AFSHandle: Record "AFS Handle"; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.ListFileHandles(Path, AFSHandle, AFSOptionalParameters));
    end;

    /// <summary>
    /// Renames a file on the file share.
    /// </summary>
    /// <param name="SourceFilePath">The path to the source file.</param>
    /// <param name="DestinationFilePath">The path to which the file will be renamed.</param>
    /// <returns>An operation response object</returns>
    procedure RenameFile(SourceFilePath: Text; DestinationFilePath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.RenameFile(SourceFilePath, DestinationFilePath, AFSOptionalParameters))
    end;

    /// <summary>
    /// Renames a file on the file share.
    /// </summary>
    /// <param name="SourceFilePath">The path to the source file.</param>
    /// <param name="DestinationFilePath">The path to which the file will be renamed.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation response object</returns>
    procedure RenameFile(SourceFilePath: Text; DestinationFilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.RenameFile(SourceFilePath, DestinationFilePath, AFSOptionalParameters))
    end;

    /// <summary>
    /// Requests a new lease. If the file does not have an active lease, the file service creates a lease on the file.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="ProposedLeaseId">The proposed id for the new lease.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(FilePath: Text; ProposedLeaseId: Guid; var LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.FileAcquireLease(FilePath, AFSOptionalParameters, ProposedLeaseId, LeaseId));
    end;

    /// <summary>
    /// Requests a new lease. If the file does not have an active lease, the file service creates a lease on the file.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="ProposedLeaseId">The proposed id for the new lease.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(FilePath: Text; ProposedLeaseId: Guid; AFSOptionalParameters: Codeunit "AFS Optional Parameters"; var LeaseId: Guid): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.FileAcquireLease(FilePath, AFSOptionalParameters, ProposedLeaseId, LeaseId));
    end;

    /// <summary>
    /// Changes a lease id to a new lease id.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="ProposedLeaseId">The proposed id for the new lease.</param>
    /// <param name="LeaseId">Previous lease id. Will be replaced by a new lease id if the request is successful.</param>
    /// <returns>Return value of type Codeunit "AFS Operation Response".</returns>
    procedure ChangeLease(FilePath: Text; ProposedLeaseId: Guid; var LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.FileChangeLease(FilePath, AFSOptionalParameters, LeaseId, ProposedLeaseId));
    end;

    /// <summary>
    /// Changes a lease id to a new lease id.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>
    /// <param name="ProposedLeaseId">The proposed id for the new lease.</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <param name="LeaseId">Previous lease id. Will be replaced by a new lease id if the request is successful.</param>
    /// <returns>Return value of type Codeunit "AFS Operation Response".</returns>
    procedure ChangeLease(FilePath: Text; ProposedLeaseId: Guid; AFSOptionalParameters: Codeunit "AFS Optional Parameters"; var LeaseId: Guid): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.FileChangeLease(FilePath, AFSOptionalParameters, LeaseId, ProposedLeaseId));
    end;

    /// <summary>
    /// Releases a lease on a File if it is no longer needed so that another client may immediately acquire a lease against the file.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be released</param>
    /// <returns>An operation reponse object</returns>
    procedure ReleaseLease(FilePath: Text; LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.FileReleaseLease(FilePath, AFSOptionalParameters, LeaseId));
    end;

    /// <summary>
    /// Releases a lease on a File if it is no longer needed so that another client may immediately acquire a lease against the file.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be released</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation reponse object</returns>
    procedure ReleaseLease(FilePath: Text; LeaseId: Guid; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.FileReleaseLease(FilePath, AFSOptionalParameters, LeaseId));
    end;

    /// <summary>
    /// Breaks a lease on a file.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    /// <returns>An operation reponse object</returns>
    procedure BreakLease(FilePath: Text; LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSFileClientImpl.FileBreakLease(FilePath, AFSOptionalParameters, LeaseId));
    end;

    /// <summary>
    /// Breaks a lease on a file.
    /// </summary>
    /// <param name="FilePath">The path to the file.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    /// <param name="AFSOptionalParameters">Optional parameters to pass with the request.</param>
    /// <returns>An operation reponse object</returns>
    procedure BreakLease(FilePath: Text; LeaseId: Guid; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSFileClientImpl.FileBreakLease(FilePath, AFSOptionalParameters, LeaseId));
    end;
}