// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

using Microsoft.Sales.History;

query 1442 "Sales Increase Headline"
{
    QueryType = Normal;
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            filter(PostDate; "Posting Date")
            {
            }

            filter(Cancelled; Cancelled)
            {
                ColumnFilter = Cancelled = const(false);
            }

            filter(Amount; Amount)
            {
                ColumnFilter = Amount = filter('>0');
            }

            column(CountInvoices)
            {
                Method = Count;
            }
        }
    }
}