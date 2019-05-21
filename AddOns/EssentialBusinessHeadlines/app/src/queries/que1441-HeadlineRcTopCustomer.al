// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

query 1441 "Top Customer Headline"
{
    QueryType = Normal;
    OrderBy = descending (SumAmountLcy);

    elements
    {
        dataitem(Customer; Customer)
        {
            column(No; "No.")
            {
            }

            column(CustomerName; Name)
            {
            }

            dataitem(CustLedgEntry; "Cust. Ledger Entry")
            {

                DataItemLink = "Customer No." = Customer."No.";
                SqlJoinType = InnerJoin;

                column(CustomerNo; "Customer No.")
                {
                }

                filter(PostDate; "Posting Date")
                {
                }

                filter(Reversed; Reversed)
                {
                    ColumnFilter = Reversed = filter (false);
                }

                filter(Amount; "Amount")
                {
                    ColumnFilter = Amount = filter ('>0');
                }
                column(SumAmountLcy; "Amount (LCY)")
                {
                    Method = Sum;
                }
            }
        }
    }
}