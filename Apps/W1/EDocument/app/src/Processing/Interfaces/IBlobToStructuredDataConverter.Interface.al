#if not CLEAN26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.eServices.EDocument;
using System.Utilities;

/// <summary>
/// Interfaces defines how to convert a blob to a structured type.
/// </summary>
interface IBlobToStructuredDataConverter
{
    ObsoleteReason = 'Use IStructureReceivedEDocument instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';

    /// <summary>
    /// Converts a given blob of data into a structured format (e.g., XML or JSON).
    /// This procedure handles the actual conversion logic based on the provided 
    /// blob and its type.
    /// </summary>
    /// <param name="EDocument">
    /// The E-Document record that contains the blob data.
    /// </param>
    /// <param name="FromTempblob">
    /// The codeunit representing the unstructured data in a temporary blob format.
    /// This is the input blob that needs to be converted.
    /// </param>
    /// <param name="FromType">
    /// The enum value representing the type of blob (e.g., PDF, XML, etc.) that 
    /// is being converted. This helps determine how the conversion will proceed.
    /// </param>
    /// <param name="ConvertedType">
    /// The enum value that will be set to the type of the converted data (e.g., JSON or XML).
    /// It indicates the resulting structure type after the conversion.
    /// </param>
    /// <param name="StructuredData">
    /// A text variable that will contain the result of the conversion.
    /// This is the structured output derived from the input blob data.
    /// </param>
    procedure Convert(
        EDocument: Record "E-Document";
        FromTempblob: Codeunit "Temp Blob";
        FromType: Integer;
        var ConvertedType: Integer) StructuredData: Text;
}
#endif