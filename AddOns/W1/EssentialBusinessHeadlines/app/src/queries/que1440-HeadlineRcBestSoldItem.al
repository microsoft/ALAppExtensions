// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

query 1440 "Best Sold Item Headline"
{
    QueryType = Normal;
    OrderBy = descending (SumQuantity);

    elements
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            filter(PostDate; "Posting Date")
            {
            }

            filter(Cancelled; Cancelled)
            {
                ColumnFilter = Cancelled = const (false);
            }

            filter(Amount; Amount)
            {
                ColumnFilter = Amount = filter ('>0');
            }

            dataitem(Line; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = SalesInvoiceHeader."No.";
                SqlJoinType = InnerJoin;

                column(ProductNo; "No.")
                {
                }

                filter(ProductType; Type)
                {
                }

                column(SumQuantity; "Quantity (Base)")
                {
                    Method = Sum;
                }
            }
        }
    }
}