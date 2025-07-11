// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;

/// <summary>
/// Interface that deals with creating a document in Business Central from the draft entities.
/// </summary>
interface IEDocumentFinishDraft
{
    /// <summary>
    /// Applies the actions of a draft to Business Central entities.
    /// </summary>
    /// <param name="EDocument">The E-Document that has a draft ready.</param>
    /// <param name="ImportEDocumentProcess"></param>
    /// <returns>The record ID of the document created in Business Central.</returns>
    procedure ApplyDraftToBC(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): RecordId;

    /// <summary>
    /// Reverts the actions specified in ApplyDraftToBC.
    /// </summary>
    /// <param name="EDocument">The E-Document that has a document in Business Central.</param>
    procedure RevertDraftActions(EDocument: Record "E-Document");

}