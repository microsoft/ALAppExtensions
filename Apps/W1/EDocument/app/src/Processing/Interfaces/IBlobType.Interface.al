// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

/// <summary>
/// Interface for Blob Type
/// </summary>
interface IBlobType
{
    /// <summary>
    /// Check if the blob type is structured
    /// </summary>
    /// <returns>True if the blob content is structured</returns>
    procedure IsStructured(): Boolean;

    /// <summary>
    /// Check if the blob type has a converter to convert its content to structured data
    /// </summary>
    /// <returns>True if the blob type has a converter</returns>
    procedure HasConverter(): Boolean;

    /// <summary>
    /// Get the converter for the blob type
    /// </summary>
    /// <returns>Converter for the blob type</returns>
    procedure GetStructuredDataConverter(): Interface IBlobToStructuredDataConverter

}