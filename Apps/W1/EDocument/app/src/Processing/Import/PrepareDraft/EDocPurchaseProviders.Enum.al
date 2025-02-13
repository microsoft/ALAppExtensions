// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

enum 6110 "E-Doc Purchase Providers" implements IVendorProvider, IPurchaseOrderProvider, IPurchaseLineAccountProvider, IUnitOfMeasureProvider
{
    Extensible = true;
    DefaultImplementation = IVendorProvider = "E-Doc. Providers", IPurchaseOrderProvider = "E-Doc. Providers", IPurchaseLineAccountProvider = "E-Doc. Providers", IUnitOfMeasureProvider = "E-Doc. Providers";

    value(0; Default)
    {
    }
}