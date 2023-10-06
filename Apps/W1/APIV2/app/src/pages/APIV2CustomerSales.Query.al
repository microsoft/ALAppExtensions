namespace Microsoft.API.V2;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

query 30000 "APIV2 - Customer Sales"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Customer Sale';
    EntitySetCaption = 'Customer Sales';
    EntityName = 'customerSale';
    EntitySetName = 'customerSales';
    QueryType = API;

    elements
    {
        dataitem(QueryElement1; Customer)
        {
            column(customerId; SystemId)
            {
                Caption = 'Id';
            }
            column(customerNumber; "No.")
            {
                Caption = 'No.';
            }
            column(name; Name)
            {
                Caption = 'Name';
            }
            dataitem(QueryElement10; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No." = QueryElement1."No.";
                SqlJoinType = LeftOuterJoin;
                DataItemTableFilter = "Document Type" = filter(Invoice | "Credit Memo");
                column(totalSalesAmount; "Sales (LCY)")
                {
                    Caption = 'Total Sales Amount';
                    Method = Sum;
                }
                filter(dateFilter; "Posting Date")
                {
                    Caption = 'Date Filter';
                }
            }
        }
    }
}

