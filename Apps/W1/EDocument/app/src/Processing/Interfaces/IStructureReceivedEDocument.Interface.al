// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument;

interface IStructureReceivedEDocument
{
    /// <summary>
    /// Specified how to structure the received E-Document Data Storage into a structured data type.
    /// For example for a PDF this could be calling ADI and populating the structured data type with the ADI result.
    /// </summary>
    /// <param name="EDocumentDataStorage"></param>
    /// <returns></returns>
    procedure StructureReceivedEDocument(EDocumentDataStorage: Record "E-Doc. Data Storage"): Interface IStructuredDataType
}