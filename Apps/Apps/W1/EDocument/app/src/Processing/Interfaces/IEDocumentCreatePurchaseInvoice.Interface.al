// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Document;

/// <summary>
/// Interface for changing the way that purchase invoices get created from an E-Document.
/// </summary>
interface IEDocumentCreatePurchaseInvoice
{
    /// <summary>
    /// Creates a purchase invoice from an E-Document with a draft ready.
    /// </summary>
    /// <param name="EDocument"></param>
    /// <returns></returns>
    procedure CreatePurchaseInvoice(EDocument: Record "E-Document"): Record "Purchase Header";

}