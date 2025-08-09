// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Document;

/// <summary>
/// Interface for changing the way that purchase credit memos get created from an E-Document.
/// </summary>
interface IEDocumentCreatePurchaseCreditMemo
{
    /// <summary>
    /// Creates a purchase credit memo from an E-Document with a draft ready.
    /// </summary>
    /// <param name="EDocument">The E-Document record to create the purchase credit memo from.</param>
    /// <returns>The created purchase header record for the credit memo.</returns>
    procedure CreatePurchaseCreditMemo(EDocument: Record "E-Document"): Record "Purchase Header";
}
