// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.eServices.EDocument;

codeunit 6388 "E-Doc. M365 Conn. Events"
{
    /// <summary>
    /// Allows to change the tag applied to the outlook emails processed
    /// </summary>
    /// <param name="EDocumentService">The record of the e-document service for which the category is being retrieved. This allows to have different categories for different e-document services if needed.</param>
    /// <param name="CategoryDescription">Out parameter. The description of the category to be applied to the outlook emails.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnGetOutlookCategoryDescription(EDocumentService: Record "E-Document Service"; var CategoryDescription: Text)
    begin
    end;
}