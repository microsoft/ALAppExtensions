// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument;

/// <summary>
/// Interface that deals with applying the actions of a draft to Business Central entities.
/// </summary>
interface IEDocumentFinishDraft
{
    /// <summary>
    /// Applies the actions of a draft to Business Central entities. Line creating a purchase invoice or upadting an existing purchase order.
    /// </summary>
    /// <param name="EDocument">The E-Document that has a draft ready.</param>
    /// <param name="ImportEDocumentProcess"></param>
    procedure ApplyDraftToBC(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters");

    /// <summary>
    /// Reverts the actions specified in ApplyDraftToBC.
    /// </summary>
    /// <param name="EDocument">The E-Document that has a document in Business Central.</param>
    procedure RevertDraftActions(EDocument: Record "E-Document");

}