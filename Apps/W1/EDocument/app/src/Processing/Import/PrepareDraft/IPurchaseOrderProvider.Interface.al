// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.Purchases.Document;

interface IPurchaseOrderProvider
{
    procedure GetPurchaseOrder(EDocumentPurchaseHeader: Record "E-Document Purchase Header"): Record "Purchase Header";
}