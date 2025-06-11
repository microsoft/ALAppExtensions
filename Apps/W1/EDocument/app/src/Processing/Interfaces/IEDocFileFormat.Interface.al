// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using System.Utilities;
using Microsoft.eServices.EDocument.Processing.Import;

/// <summary>
/// An interface representing the file format of a blob associated with an E-Document.
/// For example: PDF, XML, JSON.
///
/// It defines things in a file-level and not necessarily in terms of how the e-document will be processed.
///
/// However, the PreferredStructureDataImplementation method can be used to determine how the file format
/// will be processed into structured data. For example a PDF file may prefer to be processed by ADI.
/// As the name suggests, "preferred" means that other things may influence what implementation ends being used,
/// since it can be overriden by the integration imorting the E-Document.
/// </summary>
interface IEDocFileFormat
{
    /// <summary>
    /// File extension of the file format, such as "pdf", "xml", "json".
    /// </summary>
    /// <returns></returns>
    procedure FileExtension(): Text;

    /// <summary>
    /// A method called when we want to preview the content of the file in-client.
    /// </summary>
    /// <param name="FileName"></param>
    /// <param name="TempBlob"></param>
    procedure PreviewContent(FileName: Text; TempBlob: Codeunit "Temp Blob");

    /// <summary>
    /// The preferred implementation for processing the file format into structured data.
    /// For example, a PDF file may prefer to be processed by ADI,
    /// while an XML file is already structured.
    /// The final implementation used may depend on the integration importing the E-Document.
    /// </summary>
    /// <returns></returns>
    procedure PreferredStructureDataImplementation(): Enum "Structure Received E-Doc.";
}