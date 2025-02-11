// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.eServices.EDocument;

/// <summary>
/// Interface for E-Document actionable actions.
/// </summary>
interface IImportProcess
{

    procedure Run(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service");

}