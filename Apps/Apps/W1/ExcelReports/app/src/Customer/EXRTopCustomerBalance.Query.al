// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sales.ExcelReports;

using Microsoft.Sales.Receivables;

query 4403 "EXR Top Customer Balance"
{
    Caption = 'Top Customer Balance';
    OrderBy = descending(Balance_LCY);

    elements
    {
        dataitem(Detailed_Customer_Ledger_Entry; "Detailed Cust. Ledg. Entry")
        {
            column(Customer_No; "Customer No.")
            {
            }
            column(Balance_LCY; "Amount (LCY)")
            {
                Method = Sum;
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
            filter(CustomerPostingGroup; "Posting Group")
            {
            }
        }
    }
}
