// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Purchases.ExcelReports;

using Microsoft.Purchases.Payables;

query 4402 "EXR Top Vendor Purchase"
{
    Caption = 'Top Vendor Purchase';
    OrderBy = descending(Sum_Purch_LCY);

    elements
    {
        dataitem(Vendor_Ledger_Entry; "Vendor Ledger Entry")
        {
            column(Vendor_No; "Vendor No.")
            {
            }
            column(Sum_Purch_LCY; "Purchase (LCY)")
            {
                Method = Sum;
                ReverseSign = true;
            }
            filter(GlobalDimension1Code; "Global Dimension 1 Code")
            {
            }
            filter(GlobalDimension2Code; "Global Dimension 2 Code")
            {
            }
            filter(Currency_Code; "Currency Code")
            {
            }
            filter(VendorPostingGroup; "Vendor Posting Group")
            {
            }
            filter(Posting_Date; "Posting Date")
            {
            }
        }
    }
}
