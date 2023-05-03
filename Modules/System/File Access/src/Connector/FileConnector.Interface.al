// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// An file connector interface used to creating file accounts and handle external files.
/// </summary>
interface "File Connector"
{
    /// <summary>
    /// Gets a List of Files stored on the provided account.
    /// </summary>
    /// <param name="Path">The file path to list.</param>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Files">A list with all files stored in the path.</param>
    procedure ListFiles(Path: Text; AccountId: Guid; var Files: List of [Text]);

    /// <summary>
    /// Gets a file from the provided account.
    /// </summary>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Stream">The Stream were the file is read to.</param>
    procedure GetFile(Path: Text; AccountId: Guid; Stream: InStream);

    /// <summary>
    /// Gets a file to the provided account.
    /// </summary>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Stream">The Stream were the file is read from.</param>
    procedure SetFile(Path: Text; AccountId: Guid; Stream: OutStream);

    /// <summary>
    /// Checks if a file exists on the provided account.
    /// </summary>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <returns>Returns true if the file exists</returns>
    procedure FileExists(Path: Text; AccountId: Guid): Boolean;

    /// <summary>
    /// Deletes a file exists on the provided account.
    /// </summary>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    procedure DeleteFile(Path: Text; AccountId: Guid);

    /// <summary>
    /// Gets a List of Directories stored on the provided account.
    /// </summary>
    /// <param name="Path">The file path to list.</param>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Files">A list with all directories stored in the path.</param>
    procedure ListDirectories(Path: Text; AccountId: Guid; var Directiories: List of [Text]);

    /// <summary>
    /// Creates a directory on the provided account.
    /// </summary>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    procedure CreateDirectory(Path: Text; AccountId: Guid);

    /// <summary>
    /// Checks if a directory exists on the provided account.
    /// </summary>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <returns>Returns true if the directory exists</returns>
    procedure DirectoryExists(Path: Text; AccountId: Guid): Boolean;

    /// <summary>
    /// Deletes a directory exists on the provided account.
    /// </summary>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    procedure DeleteDirectory(Path: Text; AccountId: Guid);

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