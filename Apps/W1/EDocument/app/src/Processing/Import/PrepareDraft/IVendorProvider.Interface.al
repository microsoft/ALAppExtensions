// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Vendor;


interface IVendorProvider
{
    procedure GetVendor(EDocument: Record "E-Document"): Record Vendor;
}
