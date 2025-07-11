// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sales.ExcelReports;

using Microsoft.Sales.Receivables;

query 4404 "EXR Top Customer Sales"
{
    Caption = 'Top Customer Sale';
    OrderBy = descending(Sum_Purch_LCY);

    elements
    {
        dataitem(Customer_Ledger_Entry; "Cust. Ledger Entry")
        {
            column(Customer_No; "Customer No.")
            {
            }
            column(Sum_Purch_LCY; "Sales (LCY)")
            {
                Method = Sum;
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
            filter(CustomerPostingGroup; "Customer Posting Group")
            {
            }
            filter(Posting_Date; "Posting Date")
            {
            }
        }
    }
}
