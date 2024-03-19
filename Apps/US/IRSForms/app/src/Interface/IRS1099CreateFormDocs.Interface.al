// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

/// <summary>
/// The interface to create 1099 form documents
/// </summary>
interface "IRS 1099 Create Form Docs"
{
    /// <summary>
    /// Creates 1099 form documents
    /// </summary>
    /// <param name="TempVendFormBoxBuffer">The calculated buffer with 1099 form box amounts</param>
    /// <param name="IRS1099CalcParameters">The calculated parameters</param>
    procedure CreateFormDocs(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; IRS1099CalcParameters: Record "IRS 1099 Calc. Params");
}
