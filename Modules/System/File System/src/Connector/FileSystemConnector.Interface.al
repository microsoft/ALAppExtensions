// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// An File System Connector interface used to creating file accounts and handle external files.
/// </summary>
interface "File System Connector"
{
    /// <summary>
    /// Gets a List of Files stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="Files">A list with all files stored in the path.</param>
    procedure ListFiles(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var FileAccountContent: Record "File Account Content" temporary);

    /// <summary>
    /// Gets a file from the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read to.</param>
    procedure GetFile(AccountId: Guid; Path: Text; Stream: InStream);

    /// <summary>
    /// Gets a file to the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read from.</param>
    procedure SetFile(AccountId: Guid; Path: Text; Stream: InStream);


    /// <summary>
    /// Copies as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure CopyFile(AccountId: Guid; SourcePath: Text; TargetPath: Text);


    /// <summary>
    /// Move as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure MoveFile(AccountId: Guid; SourcePath: Text; TargetPath: Text);

    /// <summary>
    /// Checks if a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <returns>Returns true if the file exists</returns>
    procedure FileExists(AccountId: Guid; Path: Text): Boolean;

    /// <summary>
    /// Deletes a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    procedure DeleteFile(AccountId: Guid; Path: Text);

    /// <summary>
    /// Gets a List of Directories stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="Files">A list with all directories stored in the path.</param>
    procedure ListDirectories(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var FileAccountContent: Record "File Account Content" temporary);

    /// <summary>
    /// Creates a directory on the provided account.
    /// </summary>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    procedure CreateDirectory(AccountId: Guid; Path: Text);

    /// <summary>
    /// Checks if a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <returns>Returns true if the directory exists</returns>
    procedure DirectoryExists(AccountId: Guid; Path: Text): Boolean;

    /// <summary>
    /// Deletes a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure DeleteDirectory(AccountId: Guid; Path: Text);

    /// <summary>
    /// Returns the path separator of the file account.
    /// </summary>
    /// <returns>The Path separator like / or \</returns>
    procedure PathSeparator(): Text;

    /// <summary>
    /// Gets the file accounts registered for the connector.
    /// </summary>
    /// <param name="Accounts">Out variable that holds the registered file accounts for the connector.</param>
    procedure GetAccounts(var Accounts: Record "File Account");

    /// <summary>
    /// Shows the information for an file account.
    /// </summary>
    /// <param name="AccountId">The ID of the file account</param>
    procedure ShowAccountInformation(AccountId: Guid);

    /// <summary>
    /// Registers an file account for the connector.
    /// </summary>
    /// <remarks>The out parameter must hold the account ID of the added account.</remarks>
    /// <param name="Account">Out parameter with the details of the registered Account.</param>
    /// <returns>True if an account was registered.</returns>
    procedure RegisterAccount(var FileAccount: Record "File Account"): Boolean

    /// <summary>
    /// Deletes an file account for the connector.
    /// </summary>
    /// <param name="AccountId">The ID of the file account</param>
    /// <returns>True if an account was deleted.</returns>
    procedure DeleteAccount(AccountId: Guid): Boolean

    /// <summary>
    /// Provides a custom logo for the connector that shows in the Setup File Account Guide.
    /// </summary>
    /// <returns>Base64 encoded image.</returns>
    /// <remarks>The recomended image size is 128x128.</remarks>
    /// <returns>The logo of the connector is Base64 format</returns>
    procedure GetLogoAsBase64(): Text;

    /// <summary>
    /// Provides a more detailed description of the connector.
    /// </summary>
    /// <returns>A more detailed description of the connector.</returns>
    procedure GetDescription(): Text[250];
}