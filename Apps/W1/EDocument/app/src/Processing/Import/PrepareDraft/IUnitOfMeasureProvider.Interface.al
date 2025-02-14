// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument;
using Microsoft.Foundation.UOM;

interface IUnitOfMeasureProvider
{
    procedure GetUnitOfMeasure(EDocumentHeader: Record "E-Document"; EDocumentLineId: Integer; ExternalUnitOfMeasure: Text): Record "Unit of Measure"
}