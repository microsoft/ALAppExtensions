// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Vendor;

/// <summary>
/// Interface for retrieving vendor information based on an E-Document.
/// </summary>
interface IVendorProvider
{
    /// <summary>
    /// Retrieves the vendor associated with the given E-Document.
    /// </summary>
    /// <param name="EDocument">The E-Document record containing relevant details.</param>
    /// <returns>A Vendor record matching the E-Document.</returns>
    procedure GetVendor(EDocument: Record "E-Document"): Record Vendor;
}