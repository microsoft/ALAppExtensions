// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;

/// <summary>
/// Interface for retrieving an item based on an E-Document line, vendor, and unit of measure.
/// </summary>
interface IItemProvider
{
    /// <summary>
    /// Retrieves the corresponding item for a given E-Document line.
    /// </summary>
    /// <param name="EDocument">The E-Document record containing document details.</param>
    /// <param name="EDocumentLineId">The identifier of the specific line within the E-Document.</param>
    /// <param name="Vendor">The vendor associated with the E-Document.</param>
    /// <param name="UnitOfMeasure">The unit of measure related to the item.</param>
    /// <returns>An Item record matching the provided details.</returns>
    procedure GetItem(
        EDocument: Record "E-Document";
        EDocumentLineId: Integer;
        Vendor: Record Vendor;
        UnitOfMeasure: Record "Unit of Measure"
    ): Record Item;
}