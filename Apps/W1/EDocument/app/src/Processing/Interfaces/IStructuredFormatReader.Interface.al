// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using System.Utilities;


/// <summary>
/// Describe the interface for reading a structured data format into data structures.
/// The data structures will be used in the data processing flow. 
/// </summary>
interface IStructuredFormatReader
{

    /// <summary>
    /// Read the data into the E-Document data structures.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempBlob">The temporary blob that contains the data to read</param>
    /// <returns>The data process to run on the structured data.</returns>
    procedure Read(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Structured Data Process";

}