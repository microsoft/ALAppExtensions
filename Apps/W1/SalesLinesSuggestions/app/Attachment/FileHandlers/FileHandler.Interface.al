// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

/// <summary>
/// Specifies the interface for File Handler implementations.
/// </summary>
interface "File Handler"
{
    Access = Internal;

    /// <summary>
    /// Processes the  file input stream that is passed to the function.
    /// </summary>
    /// <param name="FileInputStream">InStream pointing to the file content.</param>
    /// <returns>Result of the file processing.</returns>
    procedure Process(var FileInputStream: InStream): Variant

    /// <summary>
    /// Gets the data as a table from the file based on the file handler result.
    /// </summary>
    /// <param name="FileHandlerResult">Result of the file processing.</param>
    /// <returns>List of rows where each row is a list of columns.</returns>
    procedure GetFileData(FileHandlerResultVariant: Variant): List of [List of [Text]]

    /// <summary>
    /// Finalizes the file handler.
    /// </summary>
    /// <param name="FileHandlerResult">Result of the file processing.</param>
    procedure Finalize(FileHandlerResultVariant: Variant)
}