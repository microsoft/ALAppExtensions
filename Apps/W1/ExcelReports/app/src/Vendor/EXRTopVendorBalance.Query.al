// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Purchases.ExcelReports;

using Microsoft.Purchases.Payables;

query 4401 "EXR Top Vendor Balance"
{
    Caption = 'Top Vendor Balance';
    OrderBy = descending(Balance_LCY);

    elements
    {
        dataitem(Detailed_Vendor_Ledger_Entry; "Detailed Vendor Ledg. Entry")
        {
            column(Vendor_No; "Vendor No.")
            {
            }
            column(Balance_LCY; "Amount (LCY)")
            {
                Method = Sum;
                ReverseSign = true;
            }

            filter(Posting_Date; "Posting Date")
            {
            }
            filter(InitialEntryGlobalDim1Code; "Initial Entry Global Dim. 1")
            {
            }
            filter(InitialEntryGlobalDim2Code; "Initial Entry Global Dim. 2")
            {
            }
            filter(Currency_Code; "Currency Code")
            {
            }
            filter(VendorPostingGroup; "Posting Group")
            {
            }
        }
    }
}
