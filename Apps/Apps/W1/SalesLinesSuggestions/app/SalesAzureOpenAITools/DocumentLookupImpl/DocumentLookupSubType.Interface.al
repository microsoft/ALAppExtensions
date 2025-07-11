// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

interface DocumentLookupSubType
{
    Access = Internal;

    /// <summary>
    /// This procedure is used to look up documents, copy the document lines and assign them the temporary Record Sales Line AI Suggestions.
    ///  -CustomDimension: This can be used to pass contextual information to the function.
    ///  -TempSalesLineAiSuggestion: This is a temporary record that will be used to return the sales line AI suggestions.
    /// </summary>
    procedure SearchSalesDocument(CustomDimension: Dictionary of [Text, Text]; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary);
}