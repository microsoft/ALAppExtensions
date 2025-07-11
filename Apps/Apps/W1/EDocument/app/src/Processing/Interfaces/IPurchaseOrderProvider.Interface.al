// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

/// <summary>
/// Interface for retrieving a purchase order based on an E-Document purchase header.
/// </summary>
interface IPurchaseOrderProvider
{
    /// <summary>
    /// Retrieves the corresponding purchase order for a given E-Document purchase header.
    /// </summary>
    /// <param name="EDocumentPurchaseHeader">The E-Document purchase header record containing order details.</param>
    /// <returns>A Purchase Header record matching the provided E-Document purchase header.</returns>
    procedure GetPurchaseOrder(EDocumentPurchaseHeader: Record "E-Document Purchase Header"): Record "Purchase Header";
}