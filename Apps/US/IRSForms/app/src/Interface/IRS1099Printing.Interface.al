// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

/// <summary>
/// The interface to print 1099 form documents.
/// </summary>
interface "IRS 1099 Printing"
{
    /// <summary>
    /// Saves the content of the printed form document
    /// </summary>
    /// <param name="IRS1099FormDocHeader">The current form document</param>
    /// <param name="IRS1099PrintParams">Printing parameters</param>
    /// <param name="ReplaceIfExists">Replace the existing saved printed form document</param>
    procedure SaveContentForDocument(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; IRS1099PrintParams: Record "IRS 1099 Print Params"; ReplaceIfExists: Boolean)
    /// <summary>
    /// Prints the form document
    /// </summary>
    /// <param name="IRS1099FormDocHeader">The current form document</param>
    procedure PrintContent(IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
}
