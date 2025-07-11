// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument;

/// <summary>
/// An interface representing a structured data type that can be processed by the E-Document framework.
/// It holds the state of the structured data type, such as the file format, content, and how it should be read into a draft.
/// For example:
/// - JSON with the schema returned by ADI calls
/// - XML with the PEPPOL schema
///
/// Since a single file format can have different ways of being interpreted (for example different JSON schemas)
/// the structured data type encodes that in the "Read into draft" implementation.
/// </summary>
interface IStructuredDataType
{
    /// <summary>
    /// Returns the file format of the structured data type, such as JSON or XML.
    /// </summary>
    /// <returns></returns>
    procedure GetFileFormat(): Enum "E-Doc. File Format";

    /// <summary>
    /// Returns the content of the structured data type, such as a JSON string or XML document.
    /// </summary>
    /// <returns></returns>
    procedure GetContent(): Text;

    /// <summary>
    /// Returns the how the structured data should be "parsed" / read into a draft.
    /// </summary>
    /// <returns></returns>
    procedure GetReadIntoDraftImpl(): Enum "E-Doc. Read into Draft"
}