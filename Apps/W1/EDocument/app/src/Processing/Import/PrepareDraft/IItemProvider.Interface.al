// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;

interface IItemProvider
{
    procedure GetItem(EDocument: Record "E-Document"; EDocumentLineId: Integer; Vendor: Record Vendor; UnitOfMeasure: Record "Unit of Measure"): Record Item;
}