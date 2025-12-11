// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

/// <summary>
/// The interfaces provides methods to handle the alternative customer VAT registration in the advance letter.
/// </summary>
interface "Alt. Cust. VAT Reg. Adv. CZZ"
{
    Access = Public;

    /// <summary>
    /// Initializes the VAT registration data taken from the alternative customer registration in the sales advance letter header.
    /// </summary>
    /// <param name="SalesAdvLetterHeaderCZZ">The current sales advance letter header record</param>
    /// <param name="xSalesAdvLetterHeaderCZZ">The previous version of the record</param>
    procedure Init(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")

    /// <summary>
    /// Copies the VAT registration data from the customer to the sales advance letter header.
    /// </summary>
    /// <param name="SalesAdvLetterHeaderCZZ">The current sales advance letter header record</param>
    /// <param name="xSalesAdvLetterHeaderCZZ">The previous version of the record</param>
    procedure CopyFromCustomer(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")

    /// <summary>
    /// Updates the VAT registration data when the VAT Country/Region Code is changed in the sales advance letter header.
    /// </summary>
    /// <param name="SalesAdvLetterHeaderCZZ">The current sales advance letter header record</param>
    /// <param name="xSalesAdvLetterHeaderCZZ">The previous version of the record</param>
    procedure UpdateSetupOnVATCountryChangeInSalesAdvLetterHeader(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
}