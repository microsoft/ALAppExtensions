// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.eServices.EDocument.Processing.Import.Purchase;

/// <summary>
/// Interface for determining the account assignment for a purchase line in an E-Document.
/// </summary>

interface IPurchaseLineProvider
{
    /// <summary>
    /// Determines the purchase line fields for a given E-Document purchase line.
    /// </summary>
    /// <param name="EDocumentPurchaseLine">The purchase line record from the E-Document.</param>
    procedure GetPurchaseLine(var EDocumentPurchaseLine: Record "E-Document Purchase Line");
}
