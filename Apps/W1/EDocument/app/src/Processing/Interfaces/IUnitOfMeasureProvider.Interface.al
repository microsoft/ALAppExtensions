// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.Foundation.UOM;

/// <summary>
/// Interface for retrieving the unit of measure based on an E-Document.
/// </summary>
interface IUnitOfMeasureProvider
{
    /// <summary>
    /// Retrieves the corresponding unit of measure for a given E-Document line.
    /// </summary>
    /// <param name="EDocument">The E-Document record containing document details.</param>
    /// <param name="EDocumentLineId">The identifier of the specific line within the E-Document.</param>
    /// <param name="ExternalUnitOfMeasure">The external unit of measure reference.</param>
    /// <returns>A Unit of Measure record corresponding to the provided details.</returns>
    procedure GetUnitOfMeasure(EDocument: Record "E-Document"; EDocumentLineId: Integer; ExternalUnitOfMeasure: Text): Record "Unit of Measure";
}